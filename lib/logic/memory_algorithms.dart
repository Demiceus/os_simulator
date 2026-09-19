// lib/logic/memory_algorithms.dart

class MemoryBlock {
  final int id;
  int size; // <-- FIXED: Removed 'final' so we can subtract from it
  final int originalSize;
  int? allocatedProcessId; // Null if free
  bool isOccupied;

  MemoryBlock({
    required this.id,
    required this.size,
    required this.originalSize,
    this.allocatedProcessId,
    this.isOccupied = false,
  });
}

class MemoryAlgorithm {
  List<MemoryBlock> partitions = [];
  List<int> processes = [];

  // Helper to reset memory before each run
  void _resetMemory() {
    for (var p in partitions) {
      p.size = p.originalSize;
      p.isOccupied = false;
      p.allocatedProcessId = null;
    }
  }

  void setPartitions(List<int> sizes) {
    partitions = sizes.asMap().entries.map((e) => MemoryBlock(
      id: e.key + 1,
      size: e.value,
      originalSize: e.value,
    )).toList();
  }

  void setProcesses(List<int> sizes) {
    processes = sizes;
  }

  // --- FIRST FIT ---
  List<String> runFirstFit() {
    List<String> logs = [];
    _resetMemory(); // Reset state before running

    for (int i = 0; i < processes.length; i++) {
      int processSize = processes[i];
      bool allocated = false;

      for (var block in partitions) {
        if (!block.isOccupied && block.size >= processSize) {
          block.size -= processSize; // Now works because 'size' is not final
          block.isOccupied = true;
          block.allocatedProcessId = i + 1;
          logs.add("Process ${i + 1} ($processSize%) -> Partition ${block.id}");
          allocated = true;
          break; // First Fit breaks immediately
        }
      }
      if (!allocated) {
        logs.add("Process ${i + 1} ($processSize%) -> Not Allocated");
      }
    }
    return logs;
  }

  // --- BEST FIT ---
  List<String> runBestFit() {
    List<String> logs = [];
    _resetMemory(); // Reset state before running

    for (int i = 0; i < processes.length; i++) {
      int processSize = processes[i];
      int bestIndex = -1;
      int minFragment = 999999;

      for (int j = 0; j < partitions.length; j++) {
        var block = partitions[j];
        if (!block.isOccupied && block.size >= processSize) {
          int fragment = block.size - processSize;
          if (fragment < minFragment) {
            minFragment = fragment;
            bestIndex = j;
          }
        }
      }

      if (bestIndex != -1) {
        var block = partitions[bestIndex];
        block.size -= processSize; // Now works because 'size' is not final
        block.isOccupied = true;
        block.allocatedProcessId = i + 1;
        logs.add("Process ${i + 1} ($processSize%) -> Partition ${block.id}");
      } else {
        logs.add("Process ${i + 1} ($processSize%) -> Not Allocated");
      }
    }
    return logs;
  }
}