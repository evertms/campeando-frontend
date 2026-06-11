class RequestOtpRequest {
  final String email;
  final String fullName;

  RequestOtpRequest({required this.email, required this.fullName});

  Map<String, dynamic> toJson() => {
        'email': email,
        'fullName': fullName,
      };
}

class VerifyOtpRequest {
  final String email;
  final String otp;

  VerifyOtpRequest({required this.email, required this.otp});

  Map<String, dynamic> toJson() => {
        'email': email,
        'otp': otp,
      };
}

class SubmitRegistrationRequest {
  final String email;
  final String fullName;
  final String phone;

  SubmitRegistrationRequest({
    required this.email,
    required this.fullName,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'fullName': fullName,
        'phone': phone,
      };
}
