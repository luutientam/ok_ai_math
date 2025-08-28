import 'package:flutter_ai_math_2/app.dart';

class FormulaItemData {
  static List<FormulaItem> formulaItems = [
    // Algebra
    FormulaItem(
      uid: 1,
      formulaId: 1,
      name: 'Number Rules',
      imagePath: 'assets/images/algebra_number_rules.webp',
      isSaved: false,
    ),
    FormulaItem(
      uid: 2,
      formulaId: 1,
      name: 'Expansion Rules',
      imagePath: 'assets/images/algebra_expansion_rules.webp',
      isSaved: false,
    ),
    FormulaItem(
      uid: 3,
      formulaId: 1,
      name: 'Fraction Rules',
      imagePath: 'assets/images/algebra_fraction_rules.webp',
      isSaved: false,
    ),
    FormulaItem(
      uid: 4,
      formulaId: 1,
      name: 'Absolute Rules',
      imagePath: 'assets/images/algebra_absolute_rules.webp',
      isSaved: false,
    ),
    FormulaItem(
      uid: 5,
      formulaId: 1,
      name: 'Exponent Rules',
      imagePath: 'assets/images/algebra_exponent_rules.webp',
      isSaved: false,
    ),
    FormulaItem(
      uid: 6,
      formulaId: 1,
      name: 'Radical Rules',
      imagePath: 'assets/images/algebra_radical_rules.webp',
      isSaved: false,
    ),
    FormulaItem(
      uid: 7,
      formulaId: 1,
      name: 'Factor Rules',
      imagePath: 'assets/images/algebra_factor_rules.webp',
      isSaved: false,
    ),
    FormulaItem(
      uid: 8,
      formulaId: 1,
      name: 'Factorial Rules',
      imagePath: 'assets/images/algebra_factorial_rules.webp',
      isSaved: false,
    ),
    FormulaItem(
      uid: 9,
      formulaId: 1,
      name: 'Log Rules',
      imagePath: 'assets/images/algebra_log_rules.webp',
      isSaved: false,
    ),
    FormulaItem(
      uid: 10,
      formulaId: 1,
      name: 'Undefined Rules',
      imagePath: 'assets/images/algebra_undefined.webp',
      isSaved: false,
    ),
    FormulaItem(
      uid: 11,
      formulaId: 1,
      name: 'Complex Number Rules',
      imagePath: 'assets/images/algebra_complex_number_rules.webp',
      isSaved: false,
    ),

    // derivative
    FormulaItem(
      uid: 12,
      formulaId: 2,
      name: 'Common Derivative',
      imagePath: 'assets/images/common_derivatives.webp',
      isSaved: false,
    ),
    FormulaItem(
      uid: 13,
      formulaId: 2,
      name: 'Trigonometric Derivative',
      imagePath: 'assets/images/trigonometric_derivatives.webp',
      isSaved: false,
    ),
    FormulaItem(
      uid: 14,
      formulaId: 2,
      name: 'Arc Trigonometric Derivative',
      imagePath: 'assets/images/arc_trigonometric_derivatives.webp',
      isSaved: false,
    ),
    FormulaItem(
      uid: 15,
      formulaId: 2,
      name: 'Hyperbolic Derivative',
      imagePath: 'assets/images/hyperbolic_derivatives.webp',
      isSaved: false,
    ),

    // basic integrats
    FormulaItem(
      uid: 16,
      formulaId: 3,
      name: 'Common Integrals',
      imagePath: 'assets/images/intergrats_common.webp',
      isSaved: false,
    ),
    FormulaItem(
      uid: 17,
      formulaId: 3,
      name: 'Trigonometric Integrals',
      imagePath: 'assets/images/intergrats_trigonometric.webp',
      isSaved: false,
    ),
    FormulaItem(
      uid: 18,
      formulaId: 3,
      name: 'Arc Trigonometric Integrals',
      imagePath: 'assets/images/intergrats_arc_trigonometric.webp',
      isSaved: false,
    ),
    FormulaItem(
      uid: 19,
      formulaId: 3,
      name: 'Hyperbolic Integrals',
      imagePath: 'assets/images/intergrats_hyperbolic.webp',
      isSaved: false,
    ),
    FormulaItem(
      uid: 20,
      formulaId: 3,
      name: 'Special Functions',
      imagePath: 'assets/images/intergrats_special_functions.webp',
      isSaved: false,
    ),

    // limits
    FormulaItem(
      uid: 21,
      formulaId: 4,
      name: 'Limit Properties',
      imagePath: 'assets/images/limit_properties.webp',
      isSaved: false,
    ),
    FormulaItem(
      uid: 22,
      formulaId: 4,
      name: 'Limit Infinity Properties',
      imagePath: 'assets/images/limit_infinity_properties.webp',
      isSaved: false,
    ),
    FormulaItem(
      uid: 23,
      formulaId: 4,
      name: 'Limit Continuity Properties',
      imagePath: 'assets/images/limit_indeterminate_forms.webp',
      isSaved: false,
    ),
    FormulaItem(
      uid: 24,
      formulaId: 4,
      name: 'Limit Common',
      imagePath: 'assets/images/limit_common.webp',
      isSaved: false,
    ),

    // trigonometric
    FormulaItem(
      uid: 25,
      formulaId: 5,
      name: 'Basic Edentities',
      imagePath: 'assets/images/trigonometric_basic_identities.webp',
      isSaved: false,
    ),
    FormulaItem(
      uid: 26,
      formulaId: 5,
      name: 'Pythagorean Identities',
      imagePath: 'assets/images/trigonometric_pythagorean_indentities.webp',
      isSaved: false,
    ),
    FormulaItem(
      uid: 27,
      formulaId: 5,
      name: 'Double Angle Identities',
      imagePath: 'assets/images/trigonometric_double_angle_indentities.webp',
      isSaved: false,
    ),
    FormulaItem(
      uid: 28,
      formulaId: 5,
      name: 'Sum Difference Identities',
      imagePath: 'assets/images/trigonometric_sum_difference_indentities.webp',
      isSaved: false,
    ),
    FormulaItem(
      uid: 29,
      formulaId: 5,
      name: 'Product Sum Identities',
      imagePath: 'assets/images/trigonometric_product_sum_indentities.webp',
      isSaved: false,
    ),
    FormulaItem(
      uid: 30,
      formulaId: 5,
      name: 'Triple Angle Identities',
      imagePath: 'assets/images/trigonometric_triple_angle_indentities.webp',
      isSaved: false,
    ),
    FormulaItem(
      uid: 31,
      formulaId: 5,
      name: 'Function Ranges Identities',
      imagePath: 'assets/images/trigonometric_function_ranges_indentities.webp',
      isSaved: false,
    ),
  ];
}
