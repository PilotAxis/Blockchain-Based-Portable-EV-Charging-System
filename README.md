# 🔋 Blockchain-Enabled Portable EV Charger  
### Real-Time IoT Monitoring | Blockchain Ledger | Streamlit Visualization  

---

## 📘 Introduction  
This project presents a **Blockchain-Enabled Portable Electric Vehicle (EV) Charger** that ensures **secure, transparent, and real-time monitoring** of the charging process.  
The system integrates **MATLAB/Simulink** for charger modeling and control, **Blockchain** for transaction security, and a **Streamlit-based web dashboard** for live visualization.  

The goal is to create a **smart, portable, and tamper-proof EV charging system** capable of recording every energy transaction with transparency — essential for modern e-mobility infrastructure.

---

## ⚙️ System Overview  
The project consists of three integrated layers:

| Layer | Description |
|--------|--------------|
| 🧩 **1. MATLAB/Simulink Layer** | Simulates the EV charging operation, logs real-time parameters such as voltage, current, energy, SOC, and cost. |
| 🔐 **2. Blockchain Layer** | Converts each charge session into a secure transaction, forming a blockchain ledger (`LiveLedger.csv`) with hash links to prevent tampering. |
| 💻 **3. Streamlit Dashboard** | Displays live charger metrics, plots, SOC %, energy, cost, and verifies blockchain integrity in real time. |

---

## 🧠 Key Features  
- **Portable EV Charger Simulation** using MATLAB/Simulink.  
- **Secure Blockchain Ledger** with SHA-256 transaction hashing.  
- **Real-Time Dashboard** built with Streamlit for live monitoring.  
- **SOC, Energy & Cost Calculation** based on dynamic charge parameters.  
- **Cross-Platform**: Works on Windows, macOS, or Linux.  
- **Auto-Refresh Visualization** with blockchain integrity validation.  

---

## 🧾 Project Working  

1. **Simulation**  
   - Run the Simulink model of the portable EV charger.  
   - Key parameters (`Vout`, `Iout`, `SOC`, `Energy`, `Cost`) are logged to the workspace as Timeseries variables.  

2. **Transaction Assembly**  
   - Run `assemble_transactions.m` to convert logs into blockchain-formatted data.  
   - The script generates:  
     - `Transactions.mat` → MATLAB structured data.  
     - `LiveLedger.csv` → Hash-linked blockchain ledger.  

3. **Visualization**  
   - Launch the dashboard using:
     ```bash
     python3 -m streamlit run ev_streamlit_dashboard.py
     ```
   - View live metrics (SOC, power, cost) and blockchain status updates in the browser.  

4. **Integrity Verification**  
   - Each ledger entry is validated via hash links (`PrevHash`, `Hash`).
   - Any manual modification breaks integrity → shown as **"Blockchain Integrity FAILED"** on dashboard.

---

## 🧰 Tools & Technologies  

| Software / Library | Purpose |
|---------------------|----------|
| MATLAB / Simulink | Charger modeling, logging |
| Python | Dashboard backend |
| Streamlit | Live visualization |
| Pandas | Data processing |
| Matplotlib | Plot rendering |
| SHA-256 | Blockchain hashing |

---

## ⚡ Installation  

### 1️⃣ MATLAB Side  
- Open Simulink model and run the charger simulation.  
- Ensure **To Workspace blocks** are configured as:  
  - `t_log`, `Vout_log`, `Iout_log`, `SOC_log`, `Energy_log`, `Cost_log` (Timeseries format).  
- After simulation, run:  
  ```matlab
  assemble_transactions
