import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/bloc/menu_item_bloc/bloc/menu_bloc.dart';
import 'package:pos_system_legphel/models/Menu%20Model/menu_bill_model.dart';

class CartItemWidget extends StatelessWidget {
  final MenuBillModel cartItem;

  const CartItemWidget({super.key, required this.cartItem});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(right: 10, bottom: 10),
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      child: Text(
                        cartItem.product.name.length > 16
                            ? '${cartItem.product.name.substring(0, 16)}...'
                            : cartItem.product.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      "Nu.${(cartItem.product.price * cartItem.quantity).toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(left: 20, right: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.orange[600],
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.remove,
                            size: 15,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            context
                                .read<MenuBloc>()
                                .add(ReduceCartItemQuantity(cartItem));
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        cartItem.quantity.toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.orange[600],
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.add,
                            size: 15,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            context
                                .read<MenuBloc>()
                                .add(IncreaseCartItemQuantity(cartItem));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                  ),
                  onPressed: () {
                    context.read<MenuBloc>().add(RemoveFromCart(cartItem));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
