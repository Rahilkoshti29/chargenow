import 'package:flutter/material.dart';
import 'package:chargenow/CommonWidget/textfomfield.dart';

class BatteryHealthPage extends StatefulWidget {
  const BatteryHealthPage({super.key});

  @override
  State<BatteryHealthPage> createState() => _BatteryHealthPageState();
}

class _BatteryHealthPageState extends State<BatteryHealthPage> {
  static const Color primaryGreen = Color(0xFF2ECC71);

  final _formKey = GlobalKey<FormState>();

  // Controllers
  final ageCtrl = TextEditingController();
  final kmCtrl = TextEditingController();
  final cyclesCtrl = TextEditingController();
  final chargingLevelCtrl = TextEditingController();
  final rangeDropCtrl = TextEditingController();

  String fastCharging = "Low";
  String overnightCharging = "No";
  String drivingStyle = "Normal";
  String drainSpeed = "Normal";
  String chargingTimeIncrease = "No";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2FFF7),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        centerTitle: true,
        title: const Text(
          "Battery Health Check",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new_sharp,
            color: Colors.white,
          ), // optional if icon is single-color
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 10)
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [

                // ===== ICON =====
                const Icon(Icons.battery_charging_full,
                    size: 70, color: primaryGreen),

                const SizedBox(height: 20),

                // ===== TEXTFIELDS =====
                CommonTextFormField(
                  controller: ageCtrl,
                  hintText: "Vehicle Age (years)",
                  prefixIcon: Icons.calendar_today,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter vehicle age";
                    }
                    if (double.tryParse(value) == null) {
                      return "Enter valid number";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                CommonTextFormField(
                  controller: kmCtrl,
                  hintText: "Total KM Driven",
                  prefixIcon: Icons.speed,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter KM driven";
                    }
                    if (double.tryParse(value) == null) {
                      return "Enter valid number";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                CommonTextFormField(
                  controller: cyclesCtrl,
                  hintText: "Charging Cycles per Week",
                  prefixIcon: Icons.repeat,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter charging cycles";
                    }
                    if (int.tryParse(value) == null) {
                      return "Enter valid integer";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                CommonTextFormField(
                  controller: chargingLevelCtrl,
                  hintText: "Average Charging Level (%)",
                  prefixIcon: Icons.battery_std,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter charging level";
                    }
                    final val = double.tryParse(value);
                    if (val == null) {
                      return "Enter valid number";
                    }
                    if (val < 0 || val > 100) {
                      return "Enter value between 0-100";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                CommonTextFormField(
                  controller: rangeDropCtrl,
                  hintText: "Range Drop (%)",
                  prefixIcon: Icons.trending_down,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter range drop";
                    }
                    final val = double.tryParse(value);
                    if (val == null) {
                      return "Enter valid number";
                    }
                    if (val < 0 || val > 100) {
                      return "Enter value between 0-100";
                    }
                    return null;
                  },
                ),


                const SizedBox(height: 20),

                // ===== DROPDOWNS =====
                _dropdown("Fast Charging Frequency", ["Low", "Medium", "High"],
                    fastCharging, (val) {
                      setState(() => fastCharging = val!);
                    }),

                _dropdown("Overnight Charging", ["Yes", "No"],
                    overnightCharging, (val) {
                      setState(() => overnightCharging = val!);
                    }),

                _dropdown("Driving Style", ["Normal", "Aggressive"],
                    drivingStyle, (val) {
                      setState(() => drivingStyle = val!);
                    }),

                _dropdown("Battery Drain Speed", ["Normal", "Fast"],
                    drainSpeed, (val) {
                      setState(() => drainSpeed = val!);
                    }),

                _dropdown("Charging Time Increased", ["Yes", "No"],
                    chargingTimeIncrease, (val) {
                      setState(() => chargingTimeIncrease = val!);
                    }),

                const SizedBox(height: 25),

                // ===== BUTTON =====
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _submitData();
                      }
                    },
                    child: const Text(
                      "Check Battery Health",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===== DROPDOWN WIDGET =====
  Widget _dropdown(String title, List<String> items, String value,
      Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(

          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(30),
        ),
        child: DropdownButtonFormField<String>(
          value: value,
          dropdownColor: Colors.white,
          // style: const TextStyle(
          //   color: Colors.black,
          //   fontSize: 16,
          //   fontWeight: FontWeight.w600,
          // ),

          decoration: InputDecoration(
            labelStyle: const TextStyle(color: Colors.black),
            focusColor: Colors.black,
            labelText: title,
            border: InputBorder.none,
          ),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please select $title";
            }
            return null;
          },
        ),

      ),
    );
  }

  // ===== SUBMIT FUNCTION =====
  void _submitData() {
    final data = {
      "age": ageCtrl.text,
      "km": kmCtrl.text,
      "cycles": cyclesCtrl.text,
      "charging_level": chargingLevelCtrl.text,
      "range_drop": rangeDropCtrl.text,
      "fast_charging": fastCharging,
      "overnight": overnightCharging,
      "driving_style": drivingStyle,
      "drain_speed": drainSpeed,
      "charging_time_increase": chargingTimeIncrease,
    };

    print(data);

    // 👉 NEXT STEP: SEND THIS TO ML API
  }
}
