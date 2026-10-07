# E-Commerce Conversion Funnel & Channel Analytics (Google BigQuery)

[![SQL - Google BigQuery](https://img.shields.io/badge/SQL-Google_BigQuery-blue.svg)](https://cloud.google.com/bigquery)
[![Analytics - Product & Growth](https://img.shields.io/badge/Analytics-Growth_%26_E--Commerce-orange.svg)]()

## 📌 The Business Problem
An online store gets **4,268 visitors in 30 days but only 708 of them buy (16.59%)**. Marketing spreads effort across four channels (Email, Paid Ads, Organic, Social) without knowing which ones bring real buyers, and the team doesn't know where in the journey shoppers give up.

This project uses **BigQuery SQL** on the store's event log to answer four questions:

1. **Where is the funnel leaking?** Which step between `page_view → add_to_cart → checkout_start → payment_info → purchase` loses the most users?
2. **Which channels bring buyers, not just traffic?** Does high visitor volume turn into revenue?
3. **Where does each channel fall short?** Is a weak channel losing people early (browsing) or late (checkout)?
4. **How quickly do buyers decide?** How long from first page view to purchase?

**Result in one line:** the biggest loss is *before the cart* (68.8% of visitors never add anything), checkout is healthy, and the difference between channels comes almost entirely from how many visitors reach the cart.

---

## 🗂️ Dataset & Scope
* **Source table:** `User_data.user_events` (Google BigQuery), also provided as `user_events.csv`
* **Size:** 9,381 events from 5,000 users (IDs 1001–6000), 6 products, spanning 30 Dec 2025 – 3 Feb 2026
* **Analysis window:** the last 30 days, anchored to `MAX(event_date)` (4 Jan 2026 – 3 Feb 2026). This covers 4,268 of the 5,000 users.
* **Nature of the data:** a simulated event log, not live store data. Each user has exactly one `page_view`, one traffic source, and at most one order.
* **Events:**
  * `page_view`: visit
  * `add_to_cart`: shows buying intent
  * `checkout_start`: enters the checkout flow
  * `payment_info`: enters payment details
  * `purchase`: completed order, with the order `amount`

---

## 🛠️ SQL Techniques Used

Full queries are in [`Funnel_Analysis.sql`](sql/Funnel_Analysis.sql): CTEs, `COUNT(DISTINCT CASE WHEN ...)` funnel stages, a dynamic 30-day window anchored to `MAX(event_date)`, conversion-rate calculations, `GROUP BY` channel analysis, and `TIMESTAMP_DIFF` for time-to-conversion.

---

## 📊 Key Findings

### 1. Funnel Progression
| Funnel Stage | Unique Users | Step Conversion | Drop-off | Users Lost |
| :--- | :---: | :---: | :---: | :---: |
| **1. Page View** | 4,268 | 100.00% | — | — |
| **2. Add to Cart** | 1,332 | 31.21% | **68.79%** | 2,936 |
| **3. Checkout Start** | 951 | 71.40% | 28.60% | 381 |
| **4. Payment Info** | 768 | 80.76% | 19.24% | 183 |
| **5. Purchase** | 708 | 92.19% | 7.81% | 60 |

Overall conversion: 708 ÷ 4,268 = **16.59%**. Cart-to-purchase: 708 ÷ 1,332 = **53.2%**, so **46.8% of carts are abandoned**.

> **Key insights**
> * **Biggest leak:** 68.8% of visitors leave before adding to cart (2,936 users).
> * **Second leak:** 381 carts (28.6%) never start checkout. That is more than the payment and purchase steps lose combined (243).
> * **Payment is healthy:** 92.2% of users who enter payment details complete the purchase.

### 2. Channel Performance (30-Day Window)
| Traffic Source | Visitors | Buyers | Revenue | AOV | Revenue / Visitor (RPV) | Conversion Rate | % of Traffic | % of Revenue |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Email** | 445 | 151 | $15,190.16 | $100.60 | **$34.14** | **33.93%** | 10.4% | 20.0% |
| **Paid Ads** | 820 | 173 | $18,438.42 | $106.58 | **$22.49** | 21.10% | 19.2% | 24.2% |
| **Organic** | 1,750 | 300 | $32,709.40 | $109.03 | $18.69 | 17.14% | 41.0% | 43.0% |
| **Social** | 1,253 | 84 | $9,699.95 | $115.48 | $7.74 | 6.70% | 29.4% | 12.8% |
| **Total** | **4,268** | **708** | **$76,037.93** | **$107.40** | **$17.82** | **16.59%** | 100% | 100% |

RPV = revenue ÷ visitors. AOV = revenue ÷ orders. Conversion rate = buyers ÷ visitors. They connect: **RPV = conversion rate × AOV**.

### 3. Where Each Channel Loses Users
| Traffic Source | Visitors | Reached Cart | **Visit → Cart** | Bought | **Cart → Purchase** |
| :--- | :---: | :---: | :---: | :---: | :---: |
| Email | 445 | 280 | **62.92%** | 151 | 53.93% |
| Paid Ads | 820 | 305 | 37.20% | 173 | 56.72% |
| Organic | 1,750 | 576 | 32.91% | 300 | 52.08% |
| Social | 1,253 | 171 | **13.65%** | 84 | 49.12% |

> **Key insight:** once a visitor has a cart, all four channels convert at a similar rate (49–57%). The channel gap is almost entirely at **visit → cart** (Email 62.9% vs Social 13.7%). Social's problem is getting visitors interested, not the checkout.

### 4. Time to Conversion (Buyers Only)
| Milestone | Average Duration |
| :--- | :---: |
| View → Add to Cart | 11.19 min |
| Add to Cart → Purchase | 13.36 min |
| **View → Purchase** | **24.55 min** |

These figures cover only users who bought. Buyers go from first page view to purchase in about 25 minutes on average.

---

## 💡 Recommendations

1. **Fix the browse-to-cart step first.** It loses the most users (68.8%). `page_view` counts any page, so the next step is to break view-to-cart down by `product_id` to find which products lose visitors.
2. **Audit cart-to-checkout before touching payment.** 28.6% of carts never start checkout. Check for common friction such as late shipping costs, forced account creation, or promo-code detours. Leave the payment step alone (92.2% completion).
3. **Rework Social around lead capture and retargeting.** Social brings 29.4% of traffic but 12.8% of revenue, and only 13.7% of its visitors reach the cart. Test email-capture and retargeting campaigns instead of direct-purchase ones.
4. **Protect Email and grow the list.** Email gives 20.0% of revenue from 10.4% of traffic. Its audience probably already knows the brand, so grow the list (for example with email capture for Social visitors) and test welcome, browse-abandonment and cart-reminder flows.
5. **Protect Organic.** It is the largest revenue source (43.0%) and Paid Ads has the second-best RPV ($22.49). Keep investing in SEO and content.
6. **Set paid limits on margin, not revenue.** This dataset has no ad-spend or margin data, so true acquisition cost cannot be calculated. As a framework: maximum affordable cost per customer = AOV × gross margin. *Illustration only, at an assumed 30% margin:* about $34.64 for Social and $31.97 for Paid Ads. Replace the assumption with real margin and spend before using it.

---

## ⚠️ Limitations
* **Simulated data:** results show the analysis method; the patterns are not evidence about a real store.
* **Small samples:** Social has 84 buyers, so small differences between channels should be read with caution.
* **No cost data:** no ad spend, margin or returns, so channel efficiency is measured in revenue, not profit.
* **One order per buyer:** repeat purchases and customer lifetime value cannot be measured.
* **Single traffic source per user:** no multi-touch attribution is possible.

