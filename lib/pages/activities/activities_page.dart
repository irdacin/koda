import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:koda/components/filter_chip_section.dart';
import 'package:koda/components/search_bar_field.dart';
import 'package:koda/helpers/format_number.dart';
import 'package:koda/helpers/get_current_locale.dart';
import 'package:koda/helpers/localization_mapper.dart';
import 'package:koda/models/activity_model.dart';
import 'package:koda/services/activities_service.dart';
import 'package:koda/utils/app_colors.dart';
import 'package:koda/pages/settings/profile_page.dart';

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({super.key});

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  String _searchText = "";
  DateTime? _pickedDate;
  int _indexExpand = -1;
  final ActivitiesService _activitiesService = ActivitiesService();
  late Stream<List<Activity>> _activitiesStream;

  @override
  void initState() {
    super.initState();
    _initializeActivities();
  }

  void _initializeActivities() {
    _activitiesStream = _activitiesService.getActivities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        color: Colors.blue,
        onRefresh: () async {
          setState(() {
            _activitiesStream = _activitiesService.getActivities(
              searchField: _searchText,
              pickedDate: _pickedDate,
            );
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterChipSection(),
              const SizedBox(height: 10),
              _buildActivitiesList(),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: SearchBarField(
        onSearchChanged: (value) => setState(() {
          if (value.isNotEmpty) {
            value = value[0].toUpperCase() + value.substring(1);
          }
          value = getLabelValue(context, value);

          _activitiesStream = _activitiesService.getActivities(
            searchField: value,
            pickedDate: _pickedDate,
          );
          _searchText = value;
        }),
        backgroundColor: AppColors.secondary,
        iconColor: AppColors.text,
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.of(context)
              .push(
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              )
              .then(
                (value) => setState(() {}),
              ),
          icon: Icon(
            Icons.menu,
            size: 35,
            color: AppColors.text,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildFilterChipSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: FilterChipSection(
        chipLabels: [
          Text(AppLocalizations.of(context)!.all),
          Text(AppLocalizations.of(context)!.today),
          const Icon(Icons.calendar_month, size: 16),
        ],
        onSelected: (value) {
          if (value is String) value = getLabelValue(context, value);
          setState(
            () => _pickedDate = value == "all"
                ? null
                : value == "today"
                    ? DateTime.now()
                    : value,
          );
          _activitiesStream = _activitiesService.getActivities(
            searchField: _searchText,
            pickedDate: _pickedDate,
          );
        },
        backgroundColor: AppColors.secondary,
        selectedColor: AppColors.selected,
        selectedLabelColor: AppColors.secondaryText,
        selectedIconColor: AppColors.secondaryText,
      ),
    );
  }

  Widget _buildActivitiesList() {
    return Expanded(
      child: StreamBuilder(
        stream: _activitiesStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error"),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            );
          }

          if (snapshot.data == null) {
            return Container();
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            padding: const EdgeInsets.only(bottom: 100),
            itemBuilder: (context, index) {
              return _buildActivityCard(
                index: index,
                item: snapshot.data![index],
                isExpand: _indexExpand == index,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildActivityCard({
    required int index,
    required Activity item,
    required bool isExpand,
  }) {
    final details = item.details;
    final IconData icon;
    switch (item.status) {
      case "Sold":
        icon = Icons.arrow_upward;
        break;
      case "Add":
        icon = Icons.add;
        break;
      case "Edit":
        icon = Icons.edit;
        break;
      case "Delete":
        icon = Icons.delete;
        break;
      case "In":
        icon = Icons.arrow_downward;
        break;
      default:
        icon = Icons.help;
    }
    final Color color = item.status == "Sold" || item.status == "Delete"
        ? Colors.red
        : Colors.green;

    final String day =
        DateFormat("EEEE", getCurrrentLocale(context)).format(item.timestamp);
    final String clock = DateFormat("HH:mm M/dd/yy", getCurrrentLocale(context))
        .format(item.timestamp);

    return Stack(
      children: [
        GestureDetector(
          onTap: () => details is List && details.length > 1
              ? setState(() => _indexExpand = isExpand ? -1 : index)
              : null,
          child: Card(
            margin: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
            elevation: 15,
            color: AppColors.background,
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
                    backgroundColor: color.withAlpha(25),
                    child: Icon(
                      icon,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: details is List && details.length > 1 ||
                                details.isNotEmpty
                            ? const EdgeInsets.only(top: 5)
                            : EdgeInsets.zero,
                        child: Text(
                          item.status != null
                              ? getActivityValue(context, item.status!)
                                  .toUpperCase()
                              : "",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (details is List)
                        ...details.take(isExpand ? details.length : 1).map(
                              (detail) => Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: Row(
                                  children: [
                                    Container(
                                      constraints: const BoxConstraints(
                                        minWidth: 80,
                                      ),
                                      child: Text(
                                        detail["name"]!,
                                        style: const TextStyle(fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      formatNumber(
                                        detail['qty'].toDouble(),
                                        locale: getCurrrentLocale(context),
                                      ),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    if (detail['unit'] != null) ...[
                                      const SizedBox(width: 3),
                                      Text(
                                        detail['unit'],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )
                                    ]
                                  ],
                                ),
                              ),
                            )
                      else if (details is String)
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text(
                            details,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      else
                        Container(
                          width: MediaQuery.of(context).size.width - 180,
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            "${getActivityValue(context, details["desc"])} : ${details["name"]}",
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
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
          top: 8,
          right: 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                day,
                style: const TextStyle(
                  fontSize: 10,
                ),
              ),
              Text(
                clock,
                style: const TextStyle(
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        if (details is List && details.length > 1)
          Positioned(
            bottom: 23,
            left: 10,
            right: 10,
            child: Icon(
              isExpand
                  ? Icons.keyboard_double_arrow_up_sharp
                  : Icons.keyboard_double_arrow_down_sharp,
              size: 14,
            ),
          ),
        if (details is List)
          Positioned(
            bottom: 35,
            right: 40,
            child: SizedBox(
              height: 25,
              child: OutlinedButton(
                onPressed: () => _showConfirmChoseActivitiesDialog(
                  item.status == "Sold",
                  item.details,
                ),
                style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
                child: Text(
                  AppLocalizations.of(context)!.detail,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.text,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showConfirmChoseActivitiesDialog(bool isSoldStatus, dynamic details) {
    showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Dialog(
            insetPadding: const EdgeInsets.only(
              left: 15,
              right: 15,
              top: 60,
              bottom: 100,
            ),
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: AppColors.selected,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  _buildChoseOrderLists(context, isSoldStatus, details),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildButtomDialogButton(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChoseOrderLists(
    BuildContext context,
    bool isSoldStatus,
    dynamic orderLists,
  ) {
    if (orderLists is String) {
      return Text(
        getActivityValue(
          context,
          orderLists,
        ),
      );
    }

    if (orderLists is Map<String, dynamic>) return Container();

    final Map<String, dynamic> usedStorageItemsTotal = {};
    for (final entry in orderLists) {
      final usedStorageItems = entry["usedStorageItem"];
      if (usedStorageItems != null) {
        for (final item in usedStorageItems) {
          final String id = item["id"];
          final String name = item["name"];
          final double qty = item["quantity"] ?? 0;
          final String unit = item["unit"];

          if (usedStorageItemsTotal.containsKey(id)) {
            usedStorageItemsTotal[id]!["total"] += qty;
          } else {
            usedStorageItemsTotal[id] = {
              "name": name,
              "total": qty,
              "unit": unit,
            };
          }
        }
      }
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 40, 40, 65),
        child: Column(
          children: [
            Text(
              isSoldStatus
                  ? AppLocalizations.of(context)!.orderLists
                  : AppLocalizations.of(context)!.updatedLists,
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 2,
              color: AppColors.secondaryText,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.only(
                left: 5,
                right: isSoldStatus ? 5 : 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.itemName,
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.qty,
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 2,
              color: AppColors.secondaryText,
            ),
            const SizedBox(height: 8),
            ...orderLists.map(
              (item) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['name'],
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 18,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          formatNumber(
                            item['qty'].toDouble(),
                            locale: getCurrrentLocale(context),
                          ),
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 18,
                          ),
                        ),
                        if (!isSoldStatus) ...[
                          const SizedBox(width: 3),
                          Text(
                            item["unit"],
                            style: TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 18,
                            ),
                          ),
                        ]
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (usedStorageItemsTotal.isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 2,
                color: AppColors.secondaryText,
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.itemUsed,
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 2,
                color: AppColors.secondaryText,
              ),
              const SizedBox(height: 8),
              ...usedStorageItemsTotal.values.map(
                (item) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item['name'],
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 18,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              formatNumber(
                                item['total'],
                                locale: getCurrrentLocale(context),
                              ),
                              style: TextStyle(
                                color: AppColors.secondaryText,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              item['unit'],
                              style: TextStyle(
                                color: AppColors.secondaryText,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildButtomDialogButton(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.only(left: 20, right: 4),
      decoration: BoxDecoration(
        color: AppColors.selected,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back_ios,
              color: AppColors.secondaryText,
              size: 25,
            ),
            Text(
              AppLocalizations.of(context)!.back,
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 16,
              ),
            )
          ],
        ),
      ),
    );
  }
}
