import 'package:d_view/d_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_colors.dart';
import '../config/failure.dart';
import '../config/nav.dart';
import '../datasources/shop_datasource.dart';
import '../models/shop_model.dart';
import '../providers/search_by_city_provider.dart';
import 'detail_shop_page.dart';

class SearchByCityPage extends ConsumerStatefulWidget {
  const SearchByCityPage({super.key, required this.query});
  final String query;

  @override
  ConsumerState<SearchByCityPage> createState() => _SearchByCityPageState();
}

class _SearchByCityPageState extends ConsumerState<SearchByCityPage> {
  final edtSearch = TextEditingController();
  final _focusNode = FocusNode();

  execute() {
    ShopDatasource.searchByCity(edtSearch.text).then((value) {
      setSearchByCityStatus(ref, 'Loading');
      value.fold(
        (failure) {
          switch (failure.runtimeType) {
            case ServerFailure:
              setSearchByCityStatus(ref, 'Server Error');
              break;
            case NotFoundFailure:
              setSearchByCityStatus(ref, 'Not Found');
              break;
            case ForbiddenFailure:
              setSearchByCityStatus(ref, 'You don\'t have access');
              break;
            case BadRequestFailure:
              setSearchByCityStatus(ref, 'Bad request');
              break;
            case UnauthorisedFailure:
              setSearchByCityStatus(ref, 'Unauthorised');
              break;
            default:
              setSearchByCityStatus(ref, 'Request Error');
              break;
          }
        },
        (result) {
          setSearchByCityStatus(ref, 'Success');
          List data = result['data'];
          List<ShopModel> list =
              data.map((e) => ShopModel.fromJson(e)).toList();
          ref.read(searchByCityListProvider.notifier).setData(list);
        },
      );
    });
  }

  @override
  void initState() {
    if (widget.query != '') {
      edtSearch.text = widget.query;
      execute();
    }
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Container(
          height: 40,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              const Icon(Icons.location_city,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: edtSearch,
                  focusNode: _focusNode,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search by city...',
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 16),
                  onSubmitted: (value) => execute(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _focusNode.unfocus();
              execute();
            },
          ),
        ],
      ),
      body: Consumer(
        builder: (_, wiRef, __) {
          String status = ref.watch(searchByCityStatusProvider);
          List<ShopModel> list = ref.watch(searchByCityListProvider);

          if (status == '') {
            return const Center(
              child: Text('Enter a city to search'),
            );
          }

          if (status == 'Loading') {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (status != 'Success') {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    status,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: execute,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (list.isEmpty) {
            return const Center(
              child: Text('No shops found in this city'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              ShopModel shop = list[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  onTap: () {
                    Nav.push(context, DetailShopPage(shop: shop));
                  },
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    shop.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    shop.city,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
