import '../models/category_model.dart';
import '../models/product_model.dart';
import '../providers/api_service.dart';

class ProductRepository {
  final ApiService apiService;

  ProductRepository({required this.apiService});

  Future<List<CategoryModel>> getCategories() async {
    return await apiService.getCategories();
  }

  Future<List<ProductModel>> getProducts({String? category, String? q}) async {
    return await apiService.getProducts(category: category, q: q);
  }

  Future<ProductModel> getProductById(String id) async {
    return await apiService.getProductById(id);
  }
}
