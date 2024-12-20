import 'package:flutter/material.dart';
import 'package:koda/components/filter_chip_section.dart';
import 'package:koda/components/search_bar_field.dart';
import 'package:koda/helpers/app_colors.dart';
import 'package:koda/pages/home/settings_page.dart';

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({super.key});

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  DateTime? pickedDate;
  int indexExpand = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterChipSection(),
            const SizedBox(height: 10),
            _buildActivitiesList(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: SearchBarField(
        onSearchChanged: (value) {},
        backgroundColor: AppColors.secondary,
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SettingsPage()),
          ),
          icon: const Icon(
            Icons.menu,
            size: 35,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildFilterChipSection() {
    return FilterChipSection(
      chipLabels: const [
        Text("All"),
        Text("Today"),
        Icon(Icons.calendar_month, size: 16),
      ],
      onSelected: (value) {
        print(value);
      },
      backgroundColor: AppColors.secondary,
      selectedColor: AppColors.selected,
      selectedLabelColor: AppColors.secondaryText,
      selectedIconColor: AppColors.secondaryText,
    );
  }

  Widget _buildActivitiesList() {
    return Expanded(
      child: ListView.builder(
        itemCount: 10,
        padding: const EdgeInsets.only(bottom: 100),
        itemBuilder: (context, index) {
          final bool isExpand = indexExpand == index;
          return _buildActivityCard(index, isExpand);
        },
      ),
    );
  }

  Widget _buildActivityCard(int index, bool isExpand) {
    final List<Map<String, dynamic>> details = [
      {"name": "Burger", "quantity": 5},
      {"name": "Drink", "quantity": 4},
      {"name": "Extra", "quantity": 1},
    ];

    final String day = "Tuesday";
    final String clock = "20:08 11/20/2024";

    return Stack(
      children: [
        GestureDetector(
          onTap: () => setState(() => indexExpand = isExpand ? -1 : index),
          child: Card(
            margin: const EdgeInsets.only(bottom: 20),
            elevation: 10,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(10),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.red.withAlpha(25),
                    child: const Icon(
                      Icons.north_outlined,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "SOLD",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      ...details.take(isExpand ? details.length : 1).map(
                            (detail) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  Text(
                                    detail["name"]!,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    detail["quantity"].toString(),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 15,
          right: 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                day,
                style: TextStyle(fontSize: 12),
              ),
              Text(
                clock,
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        if (details.length > 1)
          Positioned(
            bottom: 25,
            left: 10,
            right: 10,
            child: Icon(
              isExpand
                  ? Icons.keyboard_double_arrow_up_sharp
                  : Icons.keyboard_double_arrow_down_sharp,
              size: 16,
            ),
          )
      ],
    );
  }
}
