//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// bool isfinite(floating-point-type x); // constexpr since C++23

// We don't control the implementation on windows
// UNSUPPORTED: windows

#include <cassert>
#include <cmath>
#include <limits>

#include "test_macros.h"
#include "type_algorithms.h"

struct TestFloat {
  template <class T>
  static TEST_CONSTEXPR_CXX23 bool test() {
    assert(!std::isnan(std::numeric_limits<T>::max()));
    assert(!std::isnan(std::numeric_limits<T>::infinity()));
    assert(!std::isnan(std::numeric_limits<T>::min()));
    assert(!std::isnan(std::numeric_limits<T>::denorm_min()));
    assert(!std::isnan(std::numeric_limits<T>::lowest()));
    assert(!std::isnan(-std::numeric_limits<T>::infinity()));
    assert(!std::isnan(T(0)));
    assert(std::isnan(std::numeric_limits<T>::quiet_NaN()));
    assert(std::isnan(std::numeric_limits<T>::signaling_NaN()));

    return true;
  }

  template <class T>
  TEST_CONSTEXPR_CXX23 void operator()() {
    test<T>();
#if TEST_STD_VER >= 23
    static_assert(test<T>());
#endif
  }
};

struct TestInt {
  template <class T>
  static TEST_CONSTEXPR_CXX23 bool test() {
    assert(!std::isnan(std::numeric_limits<T>::max()));
    assert(!std::isnan(std::numeric_limits<T>::lowest()));
    assert(!std::isnan(T(0)));

    return true;
  }

  template <class T>
  TEST_CONSTEXPR_CXX23 void operator()() {
    test<T>();
#if TEST_STD_VER >= 23
    static_assert(test<T>());
#endif
  }
};

template <typename T>
struct ConvertibleTo {
  operator T() const { return T(); }
};

int main(int, char**) {
  types::for_each(types::floating_point_types(), TestFloat());
  types::for_each(types::integral_types(), TestInt());

  // Make sure we can call `std::isnan` with convertible types
  {
    assert(!std::isnan(ConvertibleTo<float>()));
    assert(!std::isnan(ConvertibleTo<double>()));
    assert(!std::isnan(ConvertibleTo<long double>()));
  }

  return 0;
}
