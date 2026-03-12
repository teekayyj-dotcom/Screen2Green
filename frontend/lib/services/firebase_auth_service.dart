import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '897571099842-801qivasns71gs3de36anddit35hvpsq.apps.googleusercontent.com',
  );

  // 1. Stream theo dõi trạng thái đăng nhập của user (Dùng để điều hướng UI)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 2. Lấy thông tin user hiện tại
  User? get currentUser => _auth.currentUser;

  // 3. Đăng ký tài khoản với Email & Password
  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e.code));
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  // 4. Đăng nhập với Email & Password
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e.code));
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  // 5. Social Login (Google Sign-In)
  Future<User?> signInWithGoogle() async {
    try {
      // Kích hoạt luồng xác thực Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Nếu user đóng pop-up đăng nhập
      if (googleUser == null) return null;

      // Lấy thông tin xác thực từ request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Tạo credential mới cho Firebase từ token của Google
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Đăng nhập Firebase với credential vừa tạo
      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      return userCredential.user;
    } catch (e) {
      throw Exception('Lỗi đăng nhập Google: $e');
    }
  }

  // 6. LẤY JWT TOKEN ĐỂ GỬI XUỐNG FASTAPI
  // Gọi hàm này trước mỗi request gửi xuống backend
  Future<String?> getJwtToken() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Tham số 'true' buộc Firebase refresh token nếu token cũ đã/sắp hết hạn
        return await user.getIdToken(true);
      }
      return null;
    } catch (e) {
      print("Lỗi khi lấy JWT Token: $e");
      return null;
    }
  }

  // 7. Đăng xuất
  Future<void> signOut() async {
    try {
      // Đăng xuất khỏi Google (nếu có) để tránh auto-login lần sau
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      // Đăng xuất khỏi Firebase
      await _auth.signOut();
    } catch (e) {
      throw Exception('Lỗi khi đăng xuất: $e');
    }
  }

  // Hàm phụ trợ: Map Firebase Error Code sang tiếng Việt cho UI
  String _handleAuthError(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này.';
      case 'wrong-password':
        return 'Mật khẩu không chính xác.';
      case 'email-already-in-use':
        return 'Email này đã được đăng ký.';
      case 'weak-password':
        return 'Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn (tối thiểu 6 ký tự).';
      case 'invalid-email':
        return 'Định dạng email không hợp lệ.';
      case 'user-disabled':
        return 'Tài khoản này đã bị vô hiệu hóa.';
      default:
        return 'Xác thực thất bại ($errorCode).';
    }
  }
}
