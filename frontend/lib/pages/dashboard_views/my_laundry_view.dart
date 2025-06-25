import 'package:d_info/d_info.dart';
import 'package:d_input/d_input.dart';
import 'package:d_view/d_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/config/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';

import '../../config/app_constants.dart';
import '../../config/app_format.dart';
import '../../config/app_response.dart';
import '../../config/app_session.dart';
import '../../config/failure.dart';
import '../../config/nav.dart';
import '../../datasources/laundry_datasource.dart';
import '../../models/laundry_model.dart';
import '../../models/user_model.dart';
import '../../providers/my_laundry_provider.dart';
import '../../widgets/error_background.dart';
import '../detail_laundry_page.dart';

class MyLaundryView extends ConsumerStatefulWidget {
  const MyLaundryView({super.key});

  @override
  ConsumerState<MyLaundryView> createState() => _MyLaundryViewState();
}

class _MyLaundryViewState extends ConsumerState<MyLaundryView> {
  late UserModel user;

  getMyLaundry() {
    LaundryDatasource.readByUser(user.id).then((value) {
      value.fold(
        (failure) {
          switch (failure.runtimeType) {
            case ServerFailure:
              setMyLaundryStatus(ref, 'Server Error');
              break;
            case NotFoundFailure:
              setMyLaundryStatus(ref, 'Not Found');
              break;
            case ForbiddenFailure:
              setMyLaundryStatus(ref, 'You don\'t have access');
              break;
            case BadRequestFailure:
              setMyLaundryStatus(ref, 'Bad request');
              break;
            case UnauthorisedFailure:
              setMyLaundryStatus(ref, 'Unauthorised');
              break;
            default:
              setMyLaundryStatus(ref, 'Request Error');
              break;
          }
        },
        (result) {
          setMyLaundryStatus(ref, 'Success');
          List data = result['data'];
          List<LaundryModel> laundries =
              data.map((e) => LaundryModel.fromJson(e)).toList();
          ref.read(myLaundryListProvider.notifier).setData(laundries);
        },
      );
    });
  }

  dialogClaim() {
    final edtLaundryID = TextEditingController();
    final edtClaimCode = TextEditingController();
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Claim Laundry',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  DInput(
                    controller: edtLaundryID,
                    title: 'Laundry ID',
                    radius: BorderRadius.circular(12),
                    validator: (input) => input == '' ? "Don't empty" : null,
                    inputType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  DInput(
                    controller: edtClaimCode,
                    title: 'Claim Code',
                    radius: BorderRadius.circular(12),
                    validator: (input) => input == '' ? "Don't empty" : null,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              Navigator.pop(context);
                              claimNow(edtLaundryID.text, edtClaimCode.text);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Claim Now',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  claimNow(String id, String claimCode) {
    LaundryDatasource.claim(id, claimCode).then((value) {
      value.fold(
        (failure) {
          switch (failure.runtimeType) {
            case ServerFailure:
              DInfo.toastError('Server Error');
              break;
            case NotFoundFailure:
              DInfo.toastError('Not Found');
              break;
            case ForbiddenFailure:
              DInfo.toastError('You don\'t have access');
              break;
            case BadRequestFailure:
              DInfo.toastError('Laundry has been claimed');
              break;
            case InvalidInputFailure:
              AppResponse.invalidInput(context, failure.message ?? '{}');
              break;
            case UnauthorisedFailure:
              DInfo.toastError('Unauthorised');
              break;
            default:
              DInfo.toastError('Request Error');
              break;
          }
        },
        (result) {
          DInfo.toastSuccess('Claim Success');
          getMyLaundry();
        },
      );
    });
  }

  @override
  void initState() {
    AppSession.getUser().then((value) {
      user = value!;
      getMyLaundry();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildCategoryFilter(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => getMyLaundry(),
            child: Consumer(
              builder: (_, wiRef, __) {
                String statusList = wiRef.watch(myLaundryStatusProvider);
                String statusCategory = wiRef.watch(myLaundryCategoryProvider);
                List<LaundryModel> listBackup =
                    wiRef.watch(myLaundryListProvider);

                if (statusList == '') return DView.loadingCircle();
                if (statusList != 'Success') {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
                    child: ErrorBackground(
                      ratio: 16 / 9,
                      message: statusList,
                    ),
                  );
                }

                List<LaundryModel> list = [];
                if (statusCategory == 'All') {
                  list = List.from(listBackup);
                } else {
                  list = listBackup
                      .where((element) => element.status == statusCategory)
                      .toList();
                }

                if (list.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 80),
                    child: Stack(
                      children: [
                        ErrorBackground(
                          ratio: 16 / 9,
                          message: 'No Laundry Data',
                        ),
                        Center(
                          child: IconButton(
                            onPressed: () => getMyLaundry(),
                            icon: const Icon(Icons.refresh,
                                color: Colors.white, size: 32),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GroupedListView<LaundryModel, String>(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
                  elements: list,
                  groupBy: (element) => AppFormat.justDate(element.createdAt),
                  order: GroupedListOrder.DESC,
                  itemComparator: (element1, element2) =>
                      element1.createdAt.compareTo(element2.createdAt),
                  groupSeparatorBuilder: (value) => Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 16),
                    child: Text(
                      AppFormat.shortDate(value),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  itemBuilder: (context, laundry) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Nav.push(
                              context, DetailLaundryPage(laundry: laundry));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      laundry.shop.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    AppFormat.longPrice(laundry.total),
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  if (laundry.withPickup)
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      margin: const EdgeInsets.only(right: 8),
                                      child: Text(
                                        'Pickup',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  if (laundry.withDelivery)
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      child: Text(
                                        'Delivery',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  const Spacer(),
                                  Text(
                                    '${laundry.weight}kg',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(laundry.status)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: _getStatusColor(laundry.status),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  laundry.status,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: _getStatusColor(laundry.status),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Process':
        return Colors.orange;
      case 'Done':
        return Colors.green;
      case 'Delivery':
        return Colors.blue;
      case 'Taken':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildCategoryFilter() {
    return Consumer(
      builder: (_, wiRef, __) {
        String categorySelected = wiRef.watch(myLaundryCategoryProvider);
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: AppConstants.laundryStatusCategory
                  .map(
                    (category) => Padding(
                      padding: EdgeInsets.only(
                        left:
                            category == AppConstants.laundryStatusCategory.first
                                ? 24
                                : 8,
                        right:
                            category == AppConstants.laundryStatusCategory.last
                                ? 24
                                : 8,
                      ),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: categorySelected == category,
                        onSelected: (selected) {
                          setMyLaundryCategory(ref, category);
                        },
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: categorySelected == category
                              ? Colors.white
                              : Colors.grey[700],
                        ),
                        selectedColor: AppColors.primary,
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'My Laundry',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => dialogClaim(),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Claim'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}
