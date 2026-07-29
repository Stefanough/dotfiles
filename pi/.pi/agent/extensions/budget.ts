import type { AssistantMessage } from "@earendil-works/pi-ai";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const OR_API = "https://openrouter.ai/api/v1";
const LOW_BALANCE_USD = 100;
const SESSION_WARN_USD = 2;
const FETCH_TIMEOUT_MS = 5000;

const CHEAPER: Record<string, { provider: string; id: string }> = {
	"openrouter/anthropic/claude-opus-5": { provider: "openrouter", id: "anthropic/claude-sonnet-5" },
	"openrouter/anthropic/claude-opus-4.8": { provider: "openrouter", id: "anthropic/claude-sonnet-5" },
	"openrouter/anthropic/claude-sonnet-5": { provider: "openrouter", id: "anthropic/claude-haiku-4.5" },
	"anthropic/claude-opus-4-8": { provider: "anthropic", id: "claude-sonnet-5" },
	"anthropic/claude-opus-5": { provider: "anthropic", id: "claude-sonnet-5" },
	"anthropic/claude-sonnet-5": { provider: "anthropic", id: "claude-haiku-4-5" },
};

const usd = (n: number) => (n >= 100 ? `$${n.toFixed(0)}` : `$${n.toFixed(2)}`);

export default function (pi: ExtensionAPI) {
	let orRemaining: number | null = null;
	let orMonthly: number | null = null;
	let priceCache: Map<string, { inp: number; out: number }> | null = null;

	async function getJson(url: string, apiKey?: string): Promise<any | null> {
		const controller = new AbortController();
		const timer = setTimeout(() => controller.abort(), FETCH_TIMEOUT_MS);
		try {
			const res = await fetch(url, {
				headers: apiKey ? { Authorization: `Bearer ${apiKey}` } : {},
				signal: controller.signal,
			});
			return res.ok ? await res.json() : null;
		} catch {
			return null;
		} finally {
			clearTimeout(timer);
		}
	}

	async function refreshOpenRouter(ctx: any): Promise<void> {
		const key = await ctx.modelRegistry.getApiKeyForProvider("openrouter");
		if (!key) return;
		const [credits, keyInfo] = await Promise.all([
			getJson(`${OR_API}/credits`, key),
			getJson(`${OR_API}/key`, key),
		]);
		const c = credits?.data;
		if (c && typeof c.total_credits === "number" && typeof c.total_usage === "number") {
			orRemaining = c.total_credits - c.total_usage;
		}
		const k = keyInfo?.data;
		if (k && typeof k.usage_monthly === "number") orMonthly = k.usage_monthly;
	}

	async function prices(): Promise<Map<string, { inp: number; out: number }>> {
		if (priceCache) return priceCache;
		const map = new Map<string, { inp: number; out: number }>();
		const body = await getJson(`${OR_API}/models`);
		for (const m of body?.data ?? []) {
			const p = m?.pricing;
			if (!p) continue;
			const inp = Number(p.prompt) * 1_000_000;
			const out = Number(p.completion) * 1_000_000;
			if (Number.isFinite(inp) && Number.isFinite(out)) map.set(m.id, { inp, out });
		}
		priceCache = map;
		return map;
	}

	function sessionCost(ctx: any): number {
		let cost = 0;
		for (const e of ctx.sessionManager.getBranch()) {
			if (e.type === "message" && e.message.role === "assistant") {
				cost += (e.message as AssistantMessage).usage?.cost?.total ?? 0;
			}
		}
		return cost;
	}

	function render(ctx: any): void {
		const theme = ctx.ui.theme;
		const spent = sessionCost(ctx);
		const parts: string[] = [];

		parts.push(theme.fg(spent >= SESSION_WARN_USD ? "warning" : "dim", `session ${usd(spent)}`));

		if (orRemaining !== null) {
			const low = orRemaining < LOW_BALANCE_USD;
			parts.push(theme.fg(low ? "error" : "dim", `or ${usd(orRemaining)}`));
		}

		const target = ctx.model && CHEAPER[`${ctx.model.provider}/${ctx.model.id}`];
		if (target) parts.push(theme.fg("muted", "/cheaper"));

		ctx.ui.setStatus("budget", parts.join(theme.fg("muted", " · ")));
	}

	pi.on("session_start", async (_event, ctx) => {
		render(ctx);
		await refreshOpenRouter(ctx);
		render(ctx);
	});

	pi.on("turn_end", async (_event, ctx) => render(ctx));
	pi.on("model_select", async (_event, ctx) => render(ctx));

	pi.registerCommand("budget", {
		description: "Refresh and show spend: session cost, OpenRouter balance and monthly usage",
		handler: async (_args, ctx) => {
			await refreshOpenRouter(ctx);
			render(ctx);
			const lines = [`session ${usd(sessionCost(ctx))}`];
			if (orRemaining !== null) lines.push(`openrouter remaining ${usd(orRemaining)}`);
			if (orMonthly !== null) lines.push(`openrouter this month ${usd(orMonthly)}`);
			if (ctx.model) {
				const p = (await prices()).get(ctx.model.id);
				if (p) lines.push(`${ctx.model.id} ${usd(p.inp)}/${usd(p.out)} per Mtok`);
			}
			ctx.ui.notify(lines.join("  ·  "), "info");
		},
	});

	pi.registerCommand("cheaper", {
		description: "Switch to the next cheaper model in the same provider",
		handler: async (_args, ctx) => {
			if (!ctx.model) return ctx.ui.notify("No active model", "error");
			const current = `${ctx.model.provider}/${ctx.model.id}`;
			const target = CHEAPER[current];
			if (!target) return ctx.ui.notify(`No cheaper step defined for ${current}`, "warning");

			const model = ctx.modelRegistry.find(target.provider, target.id);
			if (!model) return ctx.ui.notify(`${target.provider}/${target.id} not in catalog`, "error");
			if (!(await pi.setModel(model))) return ctx.ui.notify("No API key for that model", "error");

			const table = await prices();
			const from = table.get(ctx.model.id);
			const to = table.get(target.id);
			const saving =
				from && to && to.out > 0 ? ` (output ${(from.out / to.out).toFixed(1)}x cheaper)` : "";
			ctx.ui.notify(`Switched to ${target.provider}/${target.id}${saving}`, "info");
		},
	});
}
