/// Operation result
enum Result { Success, Failure, Unknown }

extension ToString on Result {
  String get string => toString().split('.').last;
}

Result resultFrom(String value) {
  try {
    return Result.values
        .firstWhere((v) => v.toString().split(".").last == value);
  } catch (_) {
    throw ArgumentError.value(value);
  }
}
