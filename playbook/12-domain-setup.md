# Domain Setup Playbook — From Purchase to Live

> 适用于：Next.js + Vercel 项目配置自定义域名
> 以 beprofitly.com 为实际案例

---

## 概览

```
购买域名 (Namecheap)
    ↓
在 Vercel 添加域名 → 获取 DNS 记录
    ↓
在 Namecheap 配置 DNS
    ↓
验证生效 → 更新代码和第三方服务的 URL
```

---

## Phase 1：选择域名

### 原则
- `.com` 优先，没有好的 .com 就用 `.app`（适合 SaaS）或 `.io`
- 名字简短好记，5-12个字符最佳
- 避免连字符

### 检查可用性
1. 去 **namecheap.com**
2. 搜索你想要的域名
3. 如果 .com 被占，试试：
   - 加前缀：`get` / `use` / `try` / `be`（如 beprofitly.com）
   - 换后缀：`.app` / `.io` / `.co`

---

## Phase 2：购买域名（Namecheap）

1. 搜到可用域名后加入购物车
2. 结账时的选项：

| 选项 | 建议 | 原因 |
|------|------|------|
| Domain Registration | ✅ 购买 1 年 | 必须 |
| Domain Privacy | ✅ 开启 | 免费，保护个人信息不被公开 |
| PremiumDNS | ❌ 关闭 | 不需要 |
| Stellar Web Hosting | ❌ 关闭 | 用 Vercel，不需要 |

3. 完成支付

---

## Phase 3：在 Vercel 添加域名

1. 进入 Vercel → 你的项目 → **Settings → Domains**
2. 点击 **Add**
3. 输入域名（如 `beprofitly.com`）
4. 勾选 **Redirect xxx.com to www.xxx.com**（推荐）
5. 环境选 **Production**
6. 点击 **Save**

Vercel 会显示两条需要填入的 DNS 记录：

| Type | Name | Value |
|------|------|-------|
| A | @ | 216.198.79.1 |
| CNAME | www | xxxxxxxx.vercel-dns-017.com. |

**把这两条记录记下来，下一步要用。**

---

## Phase 4：在 Namecheap 配置 DNS

1. 进入 Namecheap → Domain List → 你的域名 → **Manage**
2. 点击顶部 **Advanced DNS** 标签
3. 删除默认已有的记录（通常是 parking page 的 CNAME 和 URL Redirect）
4. 点击 **ADD NEW RECORD**，添加 Phase 3 拿到的两条记录：

| Type | Host | Value | TTL |
|------|------|-------|-----|
| A Record | @ | 216.198.79.1 | Automatic |
| CNAME Record | www | xxxxxxxx.vercel-dns-017.com. | Automatic |

5. 保存

---

## Phase 5：验证生效

回到 Vercel → Settings → Domains，观察状态：

```
🔴 Invalid Configuration  → DNS 还没生效，等待
🔄 Generating SSL Certificate → DNS 已生效，正在生成证书（1-2分钟）
✅ Valid Configuration → 完成！
```

**DNS 生效时间：** 通常几分钟内，最长可能需要几小时。

生效后在浏览器访问你的域名确认可以正常打开。

---

## Phase 6：更新代码和第三方服务

域名配置好之后，需要把旧的 vercel.app 地址替换掉：

### 6.1 更新代码中的 URL
检查代码里有没有 hardcode 的旧域名，更新 .env / Vercel 环境变量中的 NEXT_PUBLIC_URL。

### 6.2 更新 Shopify OAuth Redirect URL
1. 进入 Shopify Partners Dashboard → Apps → 你的 App → Configuration
2. 在 **Allowed redirection URL(s)** 加入新域名的 callback：
   ```
   https://www.newdomain.com/api/shopify/callback
   ```
3. 保存（旧的 vercel.app URL 可以保留，两个都有效）

### 6.3 更新其他第三方服务
根据你的项目检查：
- Facebook Pixel（如果有域名验证）
- Google Analytics
- Stripe webhook URL（如果有）
- 任何 OAuth 应用的 redirect URL

---

## 常见问题

**Q: 307 是什么？**
A: 正常的临时重定向，表示 `domain.com` 自动跳转到 `www.domain.com`。

**Q: DNS 配了很久还没生效？**
A: 最长等 24 小时。也可以用 https://dnschecker.org 查看全球 DNS 传播状态。

**Q: 需要同时保留 vercel.app 域名吗？**
A: 可以保留，两个域名都能访问。但建议把主要流量导向自定义域名。

---

## Checklist

```
□ 域名购买完成
□ Vercel 添加域名，拿到 DNS 记录
□ Namecheap Advanced DNS 删除默认记录
□ Namecheap 添加 A Record 和 CNAME Record
□ Vercel 显示 Valid Configuration
□ 浏览器访问新域名正常
□ 代码中旧域名已更新
□ Shopify OAuth redirect URL 已更新
□ 其他第三方服务 URL 已更新
```
