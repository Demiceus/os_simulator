import 'package:flutter/material.dart';
import 'logic/memory_algorithms.dart';
import 'logic/cpu_algorithms.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OS Simulator',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("OS Algorithms Simulator")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Select a Module",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              
              // MEMORY CARD
              Card(
  elevation: 4, // Adds a shadow
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Rounded corners
  child: InkWell(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MemoryScreen())),
    borderRadius: BorderRadius.circular(16),
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          // Icon Section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.memory, size: 32, color: Colors.blue),
          ),
          const SizedBox(width: 16), // Spacing between icon and text
          // Text Section
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Memory Management", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text("First Fit & Best Fit Allocation", style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    ),
  ),
), 
              
              const SizedBox(height: 20),
              
              // CPU CARD
              Card(
  elevation: 4,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  child: InkWell(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CPUScreen())),
    borderRadius: BorderRadius.circular(16),
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1), // Changed to Orange
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.computer, size: 32, color: Colors.orange), // Changed Icon
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("CPU Scheduling", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text("FCFS, SJF, SRTF, & Round Robin", style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    ),
  ),
),
              
            ],
          ),
        ),
      ),
    );
  }
}
// ================= MEMORY SCREEN  =================

class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key});
  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  final MemoryAlgorithm _algo = MemoryAlgorithm();
  
  // --- State Variables ---
  String _selectedAlgo = "First Fit";
  String _partitionMode = "Percentage"; // <-- NEW: Percentage or Equal
  List<String> _logs = [];
  List<MemoryBlock> _currentMemoryState = [];
  bool _hasRun = false;

  // --- Percentage Mode Data ---
  List<int> _partitionSizes = [100, 500, 200, 300, 600];
  List<int> _processSizes = [212, 417, 112, 426];
  final TextEditingController _newPartitionController = TextEditingController();
  final TextEditingController _newProcessController = TextEditingController();

  // --- Equal Mode Data ---
  final TextEditingController _numPartitionsController = TextEditingController(text: "5");
  int _totalMemory = 100; // Represents 100%

  // --- Methods for Percentage Mode ---
  void _addPartition() {
    int? val = int.tryParse(_newPartitionController.text);
    if (val != null && val > 0) {
      setState(() {
        _partitionSizes.add(val);
        _newPartitionController.clear();
        _hasRun = false;
      });
    }
  }

  void _addProcess() {
    int? val = int.tryParse(_newProcessController.text);
    if (val != null && val > 0) {
      setState(() {
        _processSizes.add(val);
        _newProcessController.clear();
        _hasRun = false;
      });
    }
  }

  void _removePartition(int index) {
    setState(() {
      _partitionSizes.removeAt(index);
      _hasRun = false;
    });
  }

  void _removeProcess(int index) {
    setState(() {
      _processSizes.removeAt(index);
      _hasRun = false;
    });
  }

  // --- Method to Generate Equal Partitions ---
  void _generateEqualPartitions() {
    int numParts = int.tryParse(_numPartitionsController.text) ?? 1;
    if (numParts <= 0) return;

    setState(() {
      _partitionSizes.clear();
      int equalSize = _totalMemory ~/ numParts;
      int remainder = _totalMemory % numParts;

      for (int i = 0; i < numParts; i++) {
        // Add the remainder to the last partition so the total is exactly 100%
        if (i == numParts - 1) {
          _partitionSizes.add(equalSize + remainder);
        } else {
          _partitionSizes.add(equalSize);
        }
      }
      _hasRun = false; // Reset results when mode changes
    });
  }

  // --- Simulation Logic ---
  void _runSimulation() {
    if (_partitionSizes.isEmpty || _processSizes.isEmpty) return;

    _algo.setPartitions(_partitionSizes);
    _algo.setProcesses(_processSizes);

    setState(() {
      _hasRun = true;
      if (_selectedAlgo == "First Fit") {
        _logs = _algo.runFirstFit();
      } else {
        _logs = _algo.runBestFit();
      }
      _currentMemoryState = _algo.partitions;
    });
  }

  Color _getBlockColor(MemoryBlock block) {
    if (!block.isOccupied) return Colors.green.shade400;
    final colors = [Colors.blue, Colors.purple, Colors.orange, Colors.pink, Colors.teal, Colors.indigo];
    return colors[(block.allocatedProcessId! - 1) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Memory Management"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            
            // --- SECTION 0: PARTITION MODE SELECTOR (NEW) ---
            const Text("Select Partition Mode", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: "Percentage", label: Text("By Percentage"), icon: Icon(Icons.percent)),
                ButtonSegment(value: "Equal", label: Text("Equal Parts"), icon: Icon(Icons.balance)),
              ],
              selected: {_partitionMode},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _partitionMode = newSelection.first;
                  _partitionSizes.clear();
                  _hasRun = false;
                  if (_partitionMode == "Equal") {
                    _generateEqualPartitions();
                  } else {
                    _partitionSizes = [100, 500, 200, 300, 600]; // Reset to default
                  }
                });
              },
            ),

            const SizedBox(height: 24),

            // --- SECTION 1: ALGORITHM SELECTOR ---
            const Text("Select Algorithm", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: "First Fit", label: Text("First Fit"), icon: Icon(Icons.looks_one)),
                ButtonSegment(value: "Best Fit", label: Text("Best Fit"), icon: Icon(Icons.star)),
              ],
              selected: {_selectedAlgo},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedAlgo = newSelection.first;
                  _hasRun = false;
                });
              },
            ),

            const SizedBox(height: 24),

            // --- SECTION 2: PARTITION BUILDER (CONDITIONAL) ---
            if (_partitionMode == "Percentage") ...[
              // PERCENTAGE MODE UI
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Configure Partitions (RAM)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("Total: ${_partitionSizes.fold(0, (sum, item) => sum + item)}%", style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newPartitionController,
                      decoration: const InputDecoration(hintText: "Enter partition size (e.g., 200)", isDense: true, border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _addPartition,
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(backgroundColor: Colors.blue.shade700),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _partitionSizes.asMap().entries.map((entry) {
                  int index = entry.key;
                  int size = entry.value;
                  return Chip(
                    label: Text("P${index + 1}: $size%"),
                    backgroundColor: Colors.blue.shade50,
                    side: BorderSide(color: Colors.blue.shade200),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => _removePartition(index),
                  );
                }).toList(),
              ),
            ] else ...[
              // EQUAL MODE UI
              const Text("Configure Equal Partitions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _numPartitionsController,
                      decoration: const InputDecoration(labelText: "Number of Partitions", isDense: true, border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _generateEqualPartitions,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20)),
                    child: const Text("Generate"),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Display the generated equal partitions
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _partitionSizes.asMap().entries.map((entry) {
                  int index = entry.key;
                  int size = entry.value;
                  return Chip(
                    label: Text("P${index + 1}: $size%"),
                    backgroundColor: Colors.blue.shade50,
                    side: BorderSide(color: Colors.blue.shade200),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 24),

            // --- SECTION 3: PROCESS BUILDER ---
            const Text("Configure Processes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newProcessController,
                    decoration: const InputDecoration(hintText: "Enter process size (e.g., 150)", isDense: true, border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _addProcess,
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(backgroundColor: Colors.orange.shade700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _processSizes.asMap().entries.map((entry) {
                int index = entry.key;
                int size = entry.value;
                return Chip(
                  label: Text("P${index + 1}: $size%"),
                  backgroundColor: Colors.orange.shade50,
                  side: BorderSide(color: Colors.orange.shade200),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => _removeProcess(index),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // --- RUN BUTTON ---
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _runSimulation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("ALLOCATE MEMORY", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
            ),

            const SizedBox(height: 24),

            // --- SECTION 4: VISUAL MEMORY MAP (Same as before) ---
            if (_hasRun && _currentMemoryState.isNotEmpty) ...[
              const Text("Memory Map (Visual)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: _currentMemoryState.map((block) {
                      double usagePercentage = 1 - (block.size / block.originalSize);
                      Color blockColor = _getBlockColor(block);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Partition ${block.id} (${block.originalSize}%)", style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(
                                  block.isOccupied ? "Allocated to P${block.allocatedProcessId} | Free: ${block.size}%" : "Free | Size: ${block.size}%",
                                  style: TextStyle(color: block.isOccupied ? Colors.grey.shade700 : Colors.green.shade700, fontWeight: FontWeight.w500, fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 24,
                              width: double.infinity,
                              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                children: [
                                  if (block.isOccupied)
                                    Flexible(
                                      flex: (usagePercentage * 100).toInt(),
                                      child: Container(
                                        decoration: BoxDecoration(color: blockColor, borderRadius: const BorderRadius.horizontal(left: Radius.circular(8))),
                                        alignment: Alignment.center,
                                        child: Text("P${block.allocatedProcessId}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                      ),
                                    ),
                                  Flexible(
                                    flex: 100 - (usagePercentage * 100).toInt(),
                                    child: Container(
                                      decoration: const BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.horizontal(right: Radius.circular(8))),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- SECTION 5: ALLOCATION LOGS ---
              const Text("Allocation Logs", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: _logs.map((log) {
                      bool isNotAllocated = log.contains("Not");
                      return ListTile(
                        leading: Icon(isNotAllocated ? Icons.error_outline : Icons.check_circle_outline, color: isNotAllocated ? Colors.red : Colors.green),
                        title: Text(log),
                        dense: true,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ] else if (!_hasRun) ...[
              Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(Icons.memory, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text("Configure partitions and processes, then press Allocate to see the memory map.", style: TextStyle(color: Colors.grey.shade600), textAlign: TextAlign.center),
                  ],
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}

// ================= CPU SCREEN  =================
class CPUScreen extends StatefulWidget {
  const CPUScreen({super.key});
  @override
  State<CPUScreen> createState() => _CPUScreenState();
}

class _CPUScreenState extends State<CPUScreen> {
  final CPUScheduler _scheduler = CPUScheduler();
  
  // --- State Variables ---
  String _selectedAlgo = "FCFS";
  double _quantum = 2;
  List<Map<String, dynamic>> _gantt = [];
  List<Process> _finalProcesses = [];
  bool _hasRun = false;

  // --- Dynamic Process List ---
  // Each process is a map: {'burst': int, 'arrival': int}
  List<Map<String, int>> _processes = [
    {'burst': 5, 'arrival': 0},
    {'burst': 3, 'arrival': 1},
    {'burst': 8, 'arrival': 2},
    {'burst': 6, 'arrival': 3},
  ];

  void _addProcess() {
    setState(() {
      _processes.add({'burst': 1, 'arrival': 0});
    });
  }

  void _removeProcess(int index) {
    setState(() {
      _processes.removeAt(index);
      _hasRun = false; // Reset results when list changes
    });
  }

  void _runSimulation() {
    if (_processes.isEmpty) return;

    // Build Process objects from the dynamic list
    List<Process> processes = [];
    for (int i = 0; i < _processes.length; i++) {
      processes.add(Process(
        id: i + 1,
        burstTime: _processes[i]['burst']!,
        arrivalTime: _processes[i]['arrival']!,
      ));
    }

    setState(() {
      _hasRun = true;
      if (_selectedAlgo == "FCFS") {
        _gantt = _scheduler.runFCFS(processes);
      } else if (_selectedAlgo == "SJF") {
        _gantt = _scheduler.runSJF(processes);
      } else if (_selectedAlgo == "SRTF") {
        _gantt = _scheduler.runSRTF(processes);
      } else if (_selectedAlgo == "Round Robin") {
        _gantt = _scheduler.runRoundRobin(processes, _quantum.toInt());
      }
      _finalProcesses = processes;
    });
  }

  // Helper to get a consistent color for a process ID
  Color _getProcessColor(int id) {
    final colors = [
      Colors.blue, Colors.red, Colors.green, Colors.orange, 
      Colors.purple, Colors.teal, Colors.pink, Colors.indigo
    ];
    return colors[(id - 1) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CPU Scheduling Simulator"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- SECTION 1: ALGORITHM SELECTOR (Segmented Button) ---
            const Text("1. Select Algorithm", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: "FCFS", label: Text("FCFS")),
                  ButtonSegment(value: "SJF", label: Text("SJF")),
                  ButtonSegment(value: "SRTF", label: Text("SRTF")),
                  ButtonSegment(value: "Round Robin", label: Text("RR")),
                ],
                selected: {_selectedAlgo},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _selectedAlgo = newSelection.first;
                    _hasRun = false; // Reset when algorithm changes
                  });
                },
              ),
            ),

            // --- QUANTUM SLIDER (Only for Round Robin) ---
            if (_selectedAlgo == "Round Robin") ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text("Time Quantum: ", style: TextStyle(fontWeight: FontWeight.w500)),
                  Text("${_quantum.toInt()}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                ],
              ),
              Slider(
                value: _quantum,
                min: 1,
                max: 10,
                divisions: 9,
                label: _quantum.toInt().toString(),
                onChanged: (val) => setState(() => _quantum = val),
              ),
            ],

            const SizedBox(height: 24),

            // --- SECTION 2: PROCESS BUILDER ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("2. Configure Processes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton.icon(
                  onPressed: _addProcess,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Add Process"),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true, // Important: Allows ListView inside Column
              physics: const NeverScrollableScrollPhysics(), // Disables internal scrolling
              itemCount: _processes.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        // Process ID Badge
                        Container(
                          width: 32, height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _getProcessColor(index + 1).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Text("P${index + 1}", style: TextStyle(color: _getProcessColor(index + 1), fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        const SizedBox(width: 12),
                        // Arrival Input
                        Expanded(
                          child: TextFormField(
                            initialValue: _processes[index]['arrival'].toString(),
                            decoration: const InputDecoration(labelText: "Arrival", isDense: true, border: InputBorder.none),
                            keyboardType: TextInputType.number,
                            onChanged: (val) => _processes[index]['arrival'] = int.tryParse(val) ?? 0,
                          ),
                        ),
                        // Burst Input
                        Expanded(
                          child: TextFormField(
                            initialValue: _processes[index]['burst'].toString(),
                            decoration: const InputDecoration(labelText: "Burst", isDense: true, border: InputBorder.none),
                            keyboardType: TextInputType.number,
                            onChanged: (val) => _processes[index]['burst'] = int.tryParse(val) ?? 0,
                          ),
                        ),
                        // Delete Button
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red, size: 18),
                          onPressed: () => _removeProcess(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // --- RUN BUTTON ---
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _runSimulation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("RUN SIMULATION", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
            ),

            const SizedBox(height: 24),

            // --- SECTION 3: RESULTS (Animated) ---
            if (_hasRun) ...[
              // Gantt Chart
              const Text("Gantt Chart", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              _buildGanttChart(),

              const SizedBox(height: 24),

              // Process Metrics Table
              const Text("Process Metrics", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              _buildMetricsTable(),
            ] else ...[
              // Empty State
              Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(Icons.play_circle_outline, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text("Configure processes and press Run to see results", 
                      style: TextStyle(color: Colors.grey.shade600), textAlign: TextAlign.center),
                  ],
                ),
              )
            ]
          ],
        ),
      ),
    );
  }

  // --- WIDGET: GANTT CHART VISUALIZATION ---
  Widget _buildGanttChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _gantt.asMap().entries.map((entry) {
              int index = entry.key;
              var block = entry.value;
              Color color = _getProcessColor(block['process']);

              return Row(
                children: [
                  // Time Label at the start of the block
                  Container(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text("${block['start']}", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ),
                  // The Process Block
                  Container(
                    width: 60, // Fixed width for visual consistency
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      border: Border.all(color: color, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "P${block['process']}",
                      style: TextStyle(color: color, fontWeight: FontWeight.bold),
                    ),
                  ),
                  // Time Label at the end of the last block
                  if (index == _gantt.length - 1)
                    Container(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text("${block['end']}", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // --- WIDGET: METRICS TABLE ---
  Widget _buildMetricsTable() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.blue.shade50),
          columnSpacing: 24,
          columns: const [
            DataColumn(label: Text("Process", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Arrival", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Burst", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Start", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Finish", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Waiting", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Turnaround", style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: _finalProcesses.map((p) {
            return DataRow(cells: [
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getProcessColor(p.id).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text("P${p.id}", style: TextStyle(color: _getProcessColor(p.id), fontWeight: FontWeight.bold)),
                ),
              ),
              DataCell(Text("${p.arrivalTime}")),
              DataCell(Text("${p.burstTime}")),
              DataCell(Text("${p.startTime}")),
              DataCell(Text("${p.finishTime}")),
              DataCell(Text("${p.waitingTime}", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))),
              DataCell(Text("${p.turnaroundTime}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}