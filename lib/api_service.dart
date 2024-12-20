import 'services/api_service.dart';
import 'api_service.dart';

void main() async {
  final service = ApiService();
  await service.testApi();
}

