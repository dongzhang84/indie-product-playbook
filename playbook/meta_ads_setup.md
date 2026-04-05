# Meta 广告账号设置指南

## 整体结构

```
个人 Facebook 账号（Dong Zhang）
    ↓
Meta Business Manager（一个就够，管理所有产品）
    ├── ProfitPilot → Page + 广告账户 + Dataset
    ├── AceRocket  → Page + 广告账户 + Dataset
    └── 未来产品   → Page + 广告账户 + Dataset（照样复制）
```

---

## 第一步：创建 Facebook Page

1. 进入 [business.facebook.com](https://business.facebook.com)
2. 左下角 **Settings（齿轮）** → **Business Settings**
3. 左侧 **Accounts → Pages**
4. 右上角 **+ Add → Create a new Facebook Page**
5. 填写：
   - **Page name**：产品名（如 `ProfitPilot`）
   - **Category**：选最接近的（如 `Software` 或 `Financial Service`）
   - **Bio**：一句话描述产品（可选）

---

## 第二步：创建广告账户（Ad Account）

1. 左侧 **Accounts → Ad Accounts**
2. 右上角 **+ Add → Create a new Ad Account**
3. 填写：
   - **名字**：`产品名_Ad_Account`（如 `ProfitPilot_Ad_Account`）
   - **时区**：Pacific Time
   - **货币**：USD
4. 绑定信用卡（Payment methods 标签）

> ⚠️ 新账号最多 2 个广告账户，有消费记录后可申请增加到 5 个

---

## 第三步：创建 Dataset（Meta Pixel）

1. 左侧 **Data Sources → Datasets**
2. **+ Add → Create a new dataset**
3. 填写：
   - **名字**：`产品名_Dataset`（如 `ProfitPilot_Dataset`）
   - Conversions API 勾选框：**取消勾选**
   - Categories：跳过
4. 点 **Create**
5. 下一步选择关联的广告账户：**勾选对应的 Ad Account** → Next

---

## 第四步：安装 Meta Pixel 代码（Next.js）

拿到 Pixel ID 后，在 `app/layout.tsx` 里添加：

```tsx
import Script from "next/script";

// 在 <head> 里加：
<Script id="meta-pixel" strategy="afterInteractive">
  {`!function(f,b,e,v,n,t,s)
{if(f.fbq)return;n=f.fbq=function(){n.callMethod?
n.callMethod.apply(n,arguments):n.queue.push(arguments)};
if(!f._fbq)f._fbq=n;n.push=n;n.loaded=!0;n.version='2.0';
n.queue=[];t=b.createElement(e);t.async=!0;
t.src=v;s=b.getElementsByTagName(e)[0];
s.parentNode.insertBefore(t,s)}(window, document,'script',
'https://connect.facebook.net/en_US/fbevents.js');
fbq('init', '你的Pixel ID');
fbq('track', 'PageView');`}
</Script>
<noscript>
  <img height="1" width="1" style={{ display: 'none' }}
    src="https://www.facebook.com/tr?id=你的Pixel ID&ev=PageView&noscript=1"
    alt=""
  />
</noscript>
```

---

## 第五步：验证 Pixel 是否生效

1. Deploy 网站到线上
2. 回到 Meta → **Events Manager → Dataset → Test Events**
3. 输入网站链接 → 点 **Open Website**
4. 看到 `PageView` 事件出现 → ✅ 成功

---

## ⚠️ 发广告前必须做

- [ ] 网站挂上 **Privacy Policy** 页面
- [ ] 隐私政策里包含 Meta Pixel 相关说明
- [ ] Pixel 验证生效

---

## Advanced Matching（高级匹配）

- 作用：用用户邮箱/电话匹配 Facebook 账号，提高广告精准度
- **必须先有 Privacy Policy 才能开启**
- 开启位置：Events Manager → Dataset → Settings

---

## ProfitPilot 已完成的资产

| 资产 | 名称 | ID |
|------|------|----|
| Facebook Page | ProfitPilot | 1100285816492891 |
| Ad Account | ProfitPilot_Ad_Account | 1003301232078850 |
| Dataset/Pixel | ProfitPilot_Dataset | 1200293051996529 |

---

## 以后新产品的流程

重复以上四步即可，每个产品独立隔离：
1. 创建新 Page
2. 创建新 Ad Account
3. 创建新 Dataset
4. 安装对应 Pixel 代码
