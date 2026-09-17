import psutil

def get_process_with_max_cpu():
    # Taking an initial snapshot of all processes CPU percent
    for proc in psutil.process_iter():
        proc.cpu_percent(interval=None)  # Non-blocking call, initializes cpu_percent counters

    # Waiting a brief moment to get a more accurate measurement
    time.sleep(1)  # Adjust sleep time based on how responsive you need the script to be

    max_cpu_process = None
    max_cpu_usage = 0

    # Checking the CPU usage after the sleep period
    for proc in psutil.process_iter(['name', 'cpu_percent']):
        try:
            cpu_usage = proc.info['cpu_percent']
            if cpu_usage > max_cpu_usage:
                max_cpu_usage = cpu_usage
                max_cpu_process = proc
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            continue

    if max_cpu_process:
        return max_cpu_process.info
    else:
        return None

if __name__ == "__main__":
    import time
    max_cpu_process = get_process_with_max_cpu()
    if max_cpu_process:
        print(f"Process '{max_cpu_process['name']}' is using the most CPU: {max_cpu_process['cpu_percent']}%")
    else:
        print("No active process consuming significant CPU found.")
