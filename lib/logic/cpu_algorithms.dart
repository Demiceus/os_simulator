// lib/logic/cpu_algorithms.dart

class Process {
  final int id;
  final int burstTime;
  final int arrivalTime;
  int remainingTime;
  int waitingTime = 0;
  int turnaroundTime = 0;
  int startTime = -1;   // <-- NEW
  int finishTime = 0;   // <-- NEW

  Process({required this.id, required this.burstTime, this.arrivalTime = 0}) 
      : remainingTime = burstTime;
      
  void reset() {
    remainingTime = burstTime;
    waitingTime = 0;
    turnaroundTime = 0;
    startTime = -1;
    finishTime = 0;
  }
}

class CPUScheduler {
  
  void _resetProcesses(List<Process> processes) {
    for (var p in processes) {
      p.reset();
    }
  }

  // --- FCFS ---
  List<Map<String, dynamic>> runFCFS(List<Process> processes) {
    _resetProcesses(processes);
    List<Map<String, dynamic>> gantt = [];
    int currentTime = 0;
    
    processes.sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));

    for (var p in processes) {
      if (currentTime < p.arrivalTime) {
        currentTime = p.arrivalTime; 
      }
      
      p.startTime = currentTime; // Record Start
      gantt.add({'process': p.id, 'start': currentTime, 'end': currentTime + p.burstTime});
      
      p.waitingTime = currentTime - p.arrivalTime;
      currentTime += p.burstTime;
      
      p.finishTime = currentTime; // Record Finish
      p.turnaroundTime = p.finishTime - p.arrivalTime;
    }
    return gantt;
  }

  // --- SJF (Non-Preemptive) ---
  List<Map<String, dynamic>> runSJF(List<Process> processes) {
    _resetProcesses(processes);
    List<Map<String, dynamic>> gantt = [];
    int currentTime = 0;
    int n = processes.length;
    List<bool> isCompleted = List.filled(n, false);
    
    processes.sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));

    while (true) {
      int idx = -1;
      int minBurst = 999999;

      for (int i = 0; i < n; i++) {
        if (processes[i].arrivalTime <= currentTime && !isCompleted[i]) {
          if (processes[i].burstTime < minBurst) {
            minBurst = processes[i].burstTime;
            idx = i;
          }
        }
      }

      if (idx != -1) {
        var p = processes[idx];
        
        p.startTime = currentTime; // Record Start
        gantt.add({'process': p.id, 'start': currentTime, 'end': currentTime + p.burstTime});
        
        p.waitingTime = currentTime - p.arrivalTime;
        currentTime += p.burstTime;
        
        p.finishTime = currentTime; // Record Finish
        p.turnaroundTime = p.finishTime - p.arrivalTime;
        
        isCompleted[idx] = true;
        if (isCompleted.every((element) => element == true)) break;
      } else {
        currentTime++; 
        if (currentTime > 10000) break; 
      }
    }
    return gantt;
  }

  // --- SRTF (Shortest Remaining Time First) ---
  List<Map<String, dynamic>> runSRTF(List<Process> processes) {
    _resetProcesses(processes);
    List<Map<String, dynamic>> gantt = [];
    int currentTime = 0;
    int n = processes.length;
    int completed = 0;
    
    processes.sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));

    int? lastProcessId = null;
    int lastStartTime = 0;

    while (completed != n) {
      int idx = -1;
      int minRemaining = 999999;

      for (int i = 0; i < n; i++) {
        if (processes[i].arrivalTime <= currentTime && processes[i].remainingTime > 0) {
          if (processes[i].remainingTime < minRemaining) {
            minRemaining = processes[i].remainingTime;
            idx = i;
          }
        }
      }

      if (idx != -1) {
        var p = processes[idx];
        
        // Record Start Time (Only if it hasn't started yet)
        if (p.startTime == -1) {
          p.startTime = currentTime;
        }

        if (lastProcessId == p.id) {
           // Extend block
        } else {
           if (lastProcessId != null) {
             gantt.add({'process': lastProcessId, 'start': lastStartTime, 'end': currentTime});
           }
           lastProcessId = p.id;
           lastStartTime = currentTime;
        }

        p.remainingTime -= 1;
        currentTime += 1;

        if (p.remainingTime == 0) {
          completed++;
          p.finishTime = currentTime; // Record Finish
          p.turnaroundTime = p.finishTime - p.arrivalTime;
          p.waitingTime = p.turnaroundTime - p.burstTime;
          
          gantt.add({'process': lastProcessId, 'start': lastStartTime, 'end': currentTime});
          lastProcessId = null; 
        }
      } else {
        currentTime++;
      }
    }
    return gantt;
  }

  // --- Round Robin ---
  List<Map<String, dynamic>> runRoundRobin(List<Process> processes, int quantum) {
    _resetProcesses(processes);
    List<Map<String, dynamic>> gantt = [];
    int currentTime = 0;
    int n = processes.length;
    List<Process> queue = [];
    
    processes.sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));
    
    int i = 0; 
    
    if (processes.isNotEmpty) {
      queue.add(processes[0]);
      i = 1;
    }

    while (queue.isNotEmpty) {
      Process p = queue.removeAt(0);
      
      // Record Start Time (Only if it hasn't started yet)
      if (p.startTime == -1) {
        p.startTime = currentTime;
      }

      int executionTime = (p.remainingTime < quantum) ? p.remainingTime : quantum;
      
      gantt.add({'process': p.id, 'start': currentTime, 'end': currentTime + executionTime});
      
      currentTime += executionTime;
      p.remainingTime -= executionTime;
      
      while (i < n && processes[i].arrivalTime <= currentTime) {
        queue.add(processes[i]);
        i++;
      }
      
      if (p.remainingTime > 0) {
        queue.add(p); 
      } else {
        p.finishTime = currentTime; // Record Finish
        p.turnaroundTime = p.finishTime - p.arrivalTime;
        p.waitingTime = p.turnaroundTime - p.burstTime;
      }
    }
    return gantt;
  }
}