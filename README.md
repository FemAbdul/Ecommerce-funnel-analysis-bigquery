# Ecommerce-funnel-analysis-bigquery
---

## 📌 Executive Summary
This project analyzes end-to-end user behavior across **4,200+ unique sessions** and **$76,000+ in revenue** to understand the e-commerce sales funnel, traffic acquisition quality, time-to-conversion velocities, and unit economics.

Using **Google BigQuery SQL**, the analysis identifies critical conversion drop-off points, evaluates marketing efficiency across acquisition channels (Organic, Email, Paid Ads, Social), and derives data-driven business recommendations to optimize marketing spend and checkout operations.

---

## 🎯 Business Problems Solved
1. **Funnel Leakage Identification:** At which specific milestone (`Page View` → `Add to Cart` → `Checkout Start` → `Payment Info` → `Purchase`) are potential buyers dropping off?
2. **Channel Acquisition Quality:** Does high traffic volume correlate with high revenue, or is marketing spend driving low-intent window shoppers?
3. **Conversion Velocity:** How long does it take an active user to navigate from first discovery to a finalized transaction?
4. **Unit Economics & Spend Auditing:** What are the Average Order Value (AOV) and Revenue per Visitor (RPV) thresholds required to maintain profitable Customer Acquisition Cost (CAC) margins?

---

## 🗂️ Data Architecture & Dataset Overview
* **Source Table:** `User_data.user_events` (Google BigQuery)
* **Time Horizon:** Dynamic 30-day lookback window anchored to `MAX(event_date)`
* **Event Granularity:**
  * `page_view` — Top-of-funnel browsing activity
  * `add_to_cart` — Intent demonstration
  * `checkout_start` — Funnel progression into transaction flow
  * `payment_info` — Payment method entry
  * `purchase` — Completed commercial transaction with monetary `amount`

---

## 📊 Key Findings & Metrics Summary

### 1. Funnel Progression & Conversion Drop-Off
| Funnel Stage | Unique Users | Step Conversion Rate | Drop-off Rate | Stage Share of Total |
| :--- | :---: | :---: | :---: | :---: |
| **Stage 1: Page View** | 4,291 | Baseline (100.0%) | — | 100.0% |
| **Stage 2: Add to Cart** | 1,338 | **31.18%** | **68.82%** | 31.2% |
| **Stage 3: Checkout Start** | 954 | **71.30%** | 28.70% | 22.2% |
| **Stage 4: Payment Info** | 770 | **80.71%** | 19.29% | 17.9% |
| **Stage 5: Purchase** | 709 | **92.08%** | 7.92% | **16.52% (Overall CR)** |

> **Key Insight:** The primary bottleneck is **Stage 1 → Stage 2 (Cart Abandonment / Product Consideration)** where **68.8% of visitors bounce** without carting. Conversely, the bottom-of-funnel checkout flow is extremely healthy: **92.1%** of users who enter payment complete their purchase.

---

### 2. Marketing Acquisition Efficiency (30-Day Window)
| Traffic Source | Total Visitors | Total Buyers | Total Orders | Total Revenue ($) | AOV ($) | Revenue / Visitor (RPV) | Conversion Rate |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Email** | 445 | 151 | 151 | $15,190.16 | $100.60 | **$34.14** | **33.93%** |
| **Paid Ads** | 820 | 173 | 173 | $18,438.42 | $106.58 | **$22.49** | **21.10%** |
| **Organic** | 1,750 | 300 | 300 | $32,709.40 | $109.03 | **$18.69** | **17.14%** |
| **Social** | 1,253 | 84 | 84 | $9,699.95 | **$115.48** | **$7.74** | **6.70%** |
| **Total / Blended** | **4,268** | **708** | **708** | **$76,037.93** | **$107.40** | **$17.82** | **16.59%** |

> **Key Insight:** **Email** generates **4.4x higher revenue per visitor** ($34.14 vs. $7.74) compared to **Social**, despite Social driving nearly 3x more raw visitor volume. Social is heavily populated by passive window-shoppers.

---

### 3. Time-to-Conversion Velocity
| Velocity Milestone | Average Duration (Minutes) | Interpretation |
| :--- | :---: | :--- |
| **View → Add to Cart** | **11.21 mins** | Rapid initial product evaluation |
| **Add to Cart → Purchase** | **13.35 mins** | Decisive checkout behavior once carted |
| **Total Journey (View → Purchase)** | **24.56 mins** | Overall impulse purchase cycle is under 25 minutes |

---

## 💡 Strategic Recommendations

### 1. UX & Checkout Optimization
* **Maintain the Checkout Flow:** Conversion from `Checkout Start` to `Purchase` is exceptional (**~74.3%** cumulative from cart, **92.1%** from payment). Do not overhaul the checkout layout; prioritize preventing cart abandonment higher up the funnel.
* **Optimize Top-of-Funnel Consideration:** Deploy social proof badges, clear shipping estimates, and instant size/spec guides on product detail pages to lift the 31.2% View-to-Cart benchmark.

### 2. Marketing Budget & Channel Allocation
* **Reallocate Social Media Ad Spend:** Social accounts for ~30% of traffic but converts at an anemic 6.7%. Pivot social campaigns away from generic "Traffic/Clicks" objectives toward **Lead Generation (Email Capture)** and **Retargeting**.
* **Double Down on Email Infrastructure:** Email yields our highest RPV ($34.14). Implement high-converting welcome series, browse-abandonment automations, and targeted VIP promotions.
* **Bridge Social Traffic to Email:** Introduce targeted 10% welcome discount popups specifically for incoming Social referrals to convert transient traffic into high-converting email subscribers.

### 3. Financial & CAC Guardrails
* **Audit Acquisition Cost Against Channel Unit Economics:**
  * Average Order Value across channels is **~$107 – $115**.
  * Social visitors only yield **$7.74 RPV**. If blended Social CAC exceeds $7.74 per click/session or ~$35 per customer, acquisitions on social run at a net loss.
  * Cap paid ad acquisition limits strictly below target margin thresholds.

---
