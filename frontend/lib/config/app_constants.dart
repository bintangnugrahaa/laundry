class AppConstants {
  static const appName = 'Star Laundry';

  static const _host = 'http://192.168.1.9:8000';

  static const baseURL = '$_host/api';

  static const baseImageURL = '$_host/storage';

  static const laundryStatusCategory = [
    'All',
    'Pickup',
    'Queue',
    'Process',
    'Washing',
    'Dried',
    'Ironed',
    'Done',
    'Delivery'
  ];
}
