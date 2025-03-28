import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:workshop_app/Cubit/cart_cupit_page.dart';
import 'package:workshop_app/core/design/custom_app_bar.dart';
import 'package:workshop_app/core/logic/helper_methods.dart';
import 'package:workshop_app/model/product_model.dart';
import 'package:workshop_app/core/utils/app_color.dart';
import 'package:workshop_app/service/api_service.dart';
import 'package:workshop_app/view/pages/cart/cart_page.dart';
import 'package:workshop_app/view/widget/custom_top_sell_item_product.dart';
import 'package:workshop_app/view/widget/details_page.dart';
import '../../../core/design/title_text.dart';
import '../../../core/utils/text_style_theme.dart';

class SeeAllScreen extends StatefulWidget {
  const SeeAllScreen({super.key});

  @override
  State<SeeAllScreen> createState() => _SeeAllScreenState();
}

class _SeeAllScreenState extends State<SeeAllScreen> {
  late Future<List<ProductModel>> futureProducts;

  @override
  void initState() {
    super.initState();
    futureProducts = ApiService.fetchProducts(); // Fetching products
  }

  void addToCart(ProductModel product, BuildContext context) {
    context.read<CartCubit>().addToCart(product, context);
  }

  @override
  Widget build(BuildContext context) {
    final cartState = context.watch<CartCubit>().state;
    final List<ProductModel> cartItems =
        cartState is CartLoaded
            ? List<ProductModel>.from(cartState.cart)
            : []; // ✅ Fix applied

    return Scaffold(
      backgroundColor: Color(0xffF5F5F5),
      appBar: CustomAppBar(
        height: 50.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        hideBack: false,
        action: IconButton(
          onPressed: () {
            navigateTo(
              toPage: BlocProvider.value(
                value: BlocProvider.of<CartCubit>(context),
                child: CartPage(),
              ),
            );
          },
          icon: Icon(CupertinoIcons.cart, color: AppColor.white),
        ),
        title: CustomTextWidget(
          label: "Top Sell",
          style: TextStyleTheme.textStyle20Bold,
        ),
        gradient: LinearGradient(
          colors: [
            AppColor.primary.withOpacity(.86),
            Color.fromARGB(255, 29, 196, 99),
          ],
        ),
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error fetching products"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No products available"));
          } else {
            List<ProductModel> products = snapshot.data!;

            return ListView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 47.h),
              children: [
                GridView.builder(
                  itemCount: products.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 163 / 250,
                    mainAxisSpacing: 26,
                    crossAxisSpacing: 26,
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final bool isProductInCart = cartItems.contains(product);

                    return GestureDetector(
                      onTap: () {
                        navigateTo(toPage: DetailsPage(product: product));
                      },
                      child: CustomTopSellItemProduct(
                        product: product,
                        cartItems:
                            cartItems, // ✅ Ensured it's List<ProductModel>
                        addToCartCallback:
                            (product) => addToCart(product, context),
                        isAddedToCart: isProductInCart,
                      ),
                    );
                  },
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
