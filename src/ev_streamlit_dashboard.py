# ev_streamlit_dashboard.py
import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt
import hashlib
import time
from pathlib import Path

st.set_page_config(page_title="EV Charger Live Dashboard", layout="wide", initial_sidebar_state="expanded")

DATA_FILE = Path("/Users/ahmedmajid/Documents/Blockchain Based Portable EV Charging System/data/LiveLedger.csv")
POLL_SECONDS = 1.0   # how often Streamlit polls the CSV (seconds)

# --- Helper functions ---
def safe_read_csv(path):
    """Read CSV robustly; return empty DataFrame if file missing or locked."""
    try:
        # small read; dtype inference ok
        df = pd.read_csv(path)
        return df
    except Exception as e:
        return pd.DataFrame()

def compute_row_hash(row):
    """Compute a deterministic hash for a row (similar to MATLAB JSON/hash)."""
    # select ordering of fields to be consistent
    fields = ['Timestamp','Vout','Iout','SOC','Energy','Cost']
    s = "|".join(str(row[f]) for f in fields if f in row.index)
    return hashlib.sha256(s.encode('utf-8')).hexdigest()

def validate_chain(df):
    """Validate chain using PrevHash and Hash columns if present.
       If PrevHash column missing, compute approximate chain by comparing computed hashes.
    """
    if df.empty:
        return False, "No data"
    # If explicit PrevHash/Hash provided in CSV, use them
    if 'PrevHash' in df.columns and 'Hash' in df.columns:
        # check chain
        for i in range(1, len(df)):
            prev_hash = df.loc[i-1, 'Hash']
            if str(df.loc[i, 'PrevHash']) != str(prev_hash):
                return False, f"Mismatch at index {i}: PrevHash differs"
        return True, "Chain OK (explicit hashes)"
    # Else compute derived hashes and compare (best-effort)
    computed = []
    for i in range(len(df)):
        computed.append(compute_row_hash(df.loc[i]))
    # best-effort: if df has Hash column, compare
    if 'Hash' in df.columns:
        for i in range(len(df)):
            if str(df.loc[i,'Hash']) != computed[i]:
                return False, f"Data modified at index {i}"
        return True, "Chain OK (computed hashes matched)"
    # if no hashes, cannot fully verify; return warn
    return None, "No hash columns present — integrity unknown"

# --- UI layout ---
st.title("🔋 Live EV Charger Dashboard — Blockchain Enabled")
st.sidebar.header("Controls")
st.sidebar.write("Polling interval (s)")
poll = st.sidebar.slider("Poll seconds", 0.5, 20.0, POLL_SECONDS, 0.5)

st.sidebar.markdown("---")
st.sidebar.write("Data file:")
st.sidebar.text(str(DATA_FILE.resolve()))

status_placeholder = st.empty()
col1, col2 = st.columns((2,1))

with col1:
    soc_chart = st.empty()
    energy_chart = st.empty()
with col2:
    vi_chart = st.empty()
    cost_chart = st.empty()

# Main loop: Streamlit reruns script on interaction; implement manual polling with st.button or auto-refresh
# We'll use st.experimental_rerun triggered by st_autorefresh helper from streamlit
from streamlit_autorefresh import st_autorefresh
count = st_autorefresh(interval=int(poll*1000), limit=None, key="autorefresh")

# Read data
df = safe_read_csv(DATA_FILE)
if df.empty:
    status_placeholder.info("Waiting for LiveLedger.csv... (start MATLAB simulation/server_listener)")
    st.stop()

# ensure numeric types
for col in ['Vout','Iout','SOC','Energy','Cost']:
    if col in df.columns:
        df[col] = pd.to_numeric(df[col], errors='coerce')

# Show summary metrics
total_blocks = len(df)
last_soc = df['SOC'].iloc[-1] if 'SOC' in df.columns else None
total_energy = df['Energy'].iloc[-1] if 'Energy' in df.columns else None

st.sidebar.metric("Total blocks", total_blocks)
if last_soc is not None:
    st.sidebar.metric("Final SOC (%)", f"{last_soc:.2f}")
if total_energy is not None:
    st.sidebar.metric("Energy (kWh)", f"{total_energy:.3f}")

# Plots
with col1:
    # SOC vs block index
    fig1, ax1 = plt.subplots(figsize=(8,3))
    ax1.plot(df.index, df['SOC'], marker='o', linewidth=1.6)
    ax1.set_xlabel("Block #")
    ax1.set_ylabel("SOC (%)")
    ax1.set_title("State of Charge over Blocks")
    ax1.grid(True)
    soc_chart.pyplot(fig1, use_container_width=True)

    # Energy vs block index
    fig2, ax2 = plt.subplots(figsize=(8,3))
    ax2.plot(df.index, df['Energy'], marker='s', linewidth=1.6)
    ax2.set_xlabel("Block #")
    ax2.set_ylabel("Energy (kWh)")
    ax2.set_title("Energy Delivered per Block")
    ax2.grid(True)
    energy_chart.pyplot(fig2, use_container_width=True)

with col2:
    # V-I profile (scatter)
    fig3, ax3 = plt.subplots(figsize=(4,3))
    ax3.plot(df['Vout'], df['Iout'], 'o-', linewidth=1.2)
    ax3.set_xlabel("Voltage (V)")
    ax3.set_ylabel("Current (A)")
    ax3.set_title("V–I Profile")
    ax3.grid(True)
    vi_chart.pyplot(fig3, use_container_width=True)

    # Cost bar
    fig4, ax4 = plt.subplots(figsize=(4,3))
    ax4.bar(df.index, df['Cost'])
    ax4.set_xlabel("Block #")
    ax4.set_ylabel("Cost")
    ax4.set_title("Cost per Block")
    ax4.grid(True)
    cost_chart.pyplot(fig4, use_container_width=True)

# Blockchain integrity check
valid, msg = validate_chain(df)
if valid is True:
    st.success("🔐 Blockchain integrity verified — " + msg)
elif valid is False:
    st.error("⚠️ Blockchain integrity FAILED — " + str(msg))
else:
    st.warning("ℹ️ " + str(msg))

# Show raw ledger optionally
if st.checkbox("Show ledger table", value=False):
    st.dataframe(df)