class Urls {
  static String baseURL = 'https://task-manager-api.ostad.live/api/v1';
  static String signUpURL = '$baseURL/Registration';
  static String loginURL = '$baseURL/Login';

  static String recoverVerifyEmailURL(String email) =>
      '$baseURL/RecoverVerifyEmail/${Uri.encodeComponent(email.trim())}';
  static String recoverVerifyOtpURL(String email, String otp) =>
      '$baseURL/RecoverVerifyOtp/${Uri.encodeComponent(email.trim())}/${Uri.encodeComponent(otp.trim())}';
  static String recoverResetPasswordURL = '$baseURL/RecoverResetPassword';

  static String taskStatusCountURL = '$baseURL/taskStatusCount';
  static String taskListByStatusURL(String status) =>
      '$baseURL/listTaskByStatus/$status';
  static String addNewTaskURL = '$baseURL/createTask';
  static String deleteTaskURL(String iD) => '$baseURL/deleteTask/$iD';
  static String updateTaskStatusURL(String iD, String status) =>
      '$baseURL/updateTaskStatus/$iD/$status';
  static String profileUpdateURL = '$baseURL/ProfileUpdate';
}
