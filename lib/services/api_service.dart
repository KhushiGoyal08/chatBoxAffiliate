import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ApiService {
  static const String BASE_URL =
      'https://online-media-tools-server-vercel.vercel.app';
  // static const String BASE_URL='https://localhost:8000';
  Future<Map<String, dynamic>> googleSignUp({
    required String email,
    required String profileImageUrl,
    required String mobileNumber,
    required String firstName,
    required String lastName,
  }) async {
    final url = Uri.parse('$BASE_URL/google_signup');

    final body = jsonEncode({
      'email': email,
      'profileImageUrl': profileImageUrl,
      'mobileNumber': mobileNumber,
      'firstName': firstName,
      'lastName': lastName,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        // Successful response
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        // Error response
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return {'error': errorData['message']};
      }
    } catch (error) {
      // Request failed
      return {
        'error': 'Failed to complete the signup process, please try again later'
      };
    }
  }

  Future<Map<String, dynamic>> registerAndVerifyContact(
    String mobileNumber,
  ) async {
    final String apiUrl = '$BASE_URL/api/auth/contact';

    try {
      // Create a Map to represent the JSON data
      final requestData = {'mobileNumber': mobileNumber};
      String jsonData = json.encode(requestData);
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonData,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Register And Verify User: ${response.body}");
        return {'success': true, 'message': data};
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to add user',
        };
      }
    } catch (error) {
      return {'success': false, 'message': 'Failed to add user. $error'};
    }
  }

  Future<Map<String, dynamic>> verifyUser(String mobileNumber) async {
    final String apiUrl = '$BASE_URL/api/auth/verify_User';

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode({
          'mobileNumber': mobileNumber,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else if (response.statusCode == 404) {
        final data = json.decode(response.body);
        return {'success': false, 'message': data['message']};
      } else {
        return {'success': false, 'message': 'Failed to verify contact'};
      }
    } catch (error) {
      return {'success': false, 'message': 'Failed to verify contact. $error'};
    }
  }

  // verify user

  Future<Map<String, dynamic>> getUserById(String userId) async {
    final String apiUrl = '$BASE_URL/api/users/$userId/get_user';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'],
          'user': data['user']
        };
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> data = json.decode(response.body);
        return {'success': false, 'message': data['message']};
      } else if (response.statusCode == 401) {
        final Map<String, dynamic> data = json.decode(response.body);
        return {'success': false, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch User Data, try Again Later'
        };
      }
    } catch (error) {
      // Exception handling
      return {
        'success': false,
        'message': 'Failed to fetch User Data, try Again Later'
      };
    }
  }

  Future<Map<String, dynamic>> registerAndUpdateProfile({
    required String userId,
    required File? profilePicture,
    required String firstName,
    required String lastName,
    required String email,
    required String mobileNumber,
    required String linkedIn,
    required String skype,
    required String telegram,
    required String instagram,
    required String facebook,
    required String company,
    required String designation,
    required String aboutMe,
    required String token,
    required String? flag,
  }) async {
    final String apiUrl = '$BASE_URL/api/auth/register/$userId/add_user';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // Add form fields
      request.fields['firstName'] = firstName;
      request.fields['lastName'] = lastName;
      request.fields['email'] = email;
      request.fields['mobileNumber'] = mobileNumber;
      request.fields['LinkedIn'] = linkedIn;
      request.fields['Skype'] = skype;
      request.fields['Telegram'] = telegram;
      request.fields['Instagram'] = instagram;
      request.fields['Facebook'] = facebook;
      request.fields['Company'] = company;
      request.fields['Designation'] = designation;
      request.fields['AboutMe'] = aboutMe;
      request.fields['token'] = token!;
      request.fields['flag'] = flag!;

      // Add profile picture if available
      if (profilePicture != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'ProfilePicture',
          profilePicture.path,
        ));
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        final data = await response.stream.bytesToString();
        return {'success': true, 'data': json.decode(data)};
      } else if (response.statusCode == 404) {
        final data = await response.stream.bytesToString();
        return {'success': false, 'message': json.decode(data)['message']};
      } else {
        final data = await response.stream.bytesToString();
        return {'success': false, 'message': 'Failed to Sign Up'};
      }
    } catch (error) {
      return {'success': false, 'message': 'Failed to Sign Up. $error'};
    }
  }

  Future<Map<String, dynamic>> updateUserToken(
      String userId, String updateToken) async {
    final url = Uri.parse('$BASE_URL/api/auth/$userId/update_token');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'updateToken': updateToken});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message': responseData['message'],
          'existingUser': responseData['existingUser'],
        };
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'No User Found'};
      } else if (response.statusCode == 400) {
        return {'success': false, 'message': 'Empty Update Token'};
      } else {
        return {
          'success': false,
          'message': 'Failed to Update Token, try Again Later'
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Failed to communicate with the server'
      };
    }
  }

  Future<Map<String, dynamic>> addPost(String userId,
      {String? postContent, File? postMedia, String? tag}) async {
    final String apiUrl = '$BASE_URL/api/posts/$userId/posts/add_post';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      if (postContent != null) {
        request.fields['postContent'] = postContent;
      }
      if (tag != null) {
        request.fields['tag'] = tag;
      }

      if (postMedia != null) {
        request.files.add(
            await http.MultipartFile.fromPath('postMedia', postMedia.path));
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        final data = await response.stream.bytesToString();
        print(data);
        return {'success': true, 'data': json.decode(data)};
      } else if (response.statusCode == 404) {
        final data = await response.stream.bytesToString();
        return {'success': false, 'message': json.decode(data)['message']};
      } else if (response.statusCode == 403) {
        final data = await response.stream.bytesToString();
        return {'success': false, 'message': json.decode(data)['message']};
      } else {
        final data = await response.stream.bytesToString();
        return {'success': false, 'message': 'Failed to upload post'};
      }
    } catch (error) {
      return {'success': false, 'message': 'Failed to upload post'};
    }
  }

  Future<Map<String, dynamic>> editPost(String postId, String newPostContent,
      File? newPostMedia, String tag) async {
    final String apiUrl = '$BASE_URL/api/posts/$postId/edit_post';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.fields['postContent'] = newPostContent;
      request.fields['tag'] = tag;

      // If there's a new post media, add it to the request
      if (newPostMedia != null) {
        request.files.add(
          await http.MultipartFile.fromPath('postMedia', newPostMedia.path),
        );
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        final data = await response.stream.bytesToString();
        return {'success': true, 'data': json.decode(data)};
      } else if (response.statusCode == 404) {
        final data = await response.stream.bytesToString();
        return {'success': false, 'message': json.decode(data)['message']};
      } else {
        final data = await response.stream.bytesToString();
        return {'success': false, 'message': 'Failed to edit post'};
      }
    } catch (error) {
      return {'success': false, 'message': 'Failed to edit post'};
    }
  }

  Future<Map<String, dynamic>> verifyUserToken(
      String userId, String token) async {
    Map<String, String> headers = {'Authorization': 'Bearer $token'};

    try {
      final http.Response response = await http.get(
        Uri.parse(
            "https://online-media-tools-server-vercel.vercel.app/api/users/$userId/verfiy_user_token"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> userData = jsonDecode(response.body);
        return {'success': true, 'userData': userData};
      } else {
        Map<String, dynamic> error = jsonDecode(response.body);
        return {'success': false, 'error': error};
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to verify user token. Try again later.'
      };
    }
  }

  Future<Map<String, dynamic>> searchPosts(String searchQuery) async {
    final String apiUrl = '$BASE_URL/api/posts/search';

    try {
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      final Map<String, dynamic> requestBody = {
        'searchQuery': searchQuery,
      };

      final http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'],
          'searchResults': responseData['searchResults'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'],
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Failed to perform the search',
      };
    }
  }

  Future<List<Post>> getAllPosts(int postLimit) async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/api/posts/get_all_posts/$postLimit'),
        // Additional headers can be added here if needed
      );

      if (response.statusCode == 200) {
        // Successful response
        final List<dynamic> postsData = json.decode(response.body)['posts'];
        // Map the dynamic list to a List<Post>
        List<Post> posts =
            postsData.map((postData) => Post.fromJson(postData)).toList();
        return posts;
      } else if (response.statusCode == 404) {
        // Posts not found
        return [];
      } else {
        // Failed to fetch posts
        throw Exception('Failed to fetch posts');
      }
    } catch (error) {
      // Handle network or other errors
      print('Error fetching posts: $error');
      throw Exception('Failed to fetch posts');
    }
  }

  Future<List<Map<String, dynamic>>> getPinnedPosts() async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/api/PinnedPosts/get_all_Pinned'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> data = jsonData['posts'];

        List<Map<String, dynamic>> pinnedPosts =
            List<Map<String, dynamic>>.from(data);
        print("Pinned Post \n ${pinnedPosts}");
        return pinnedPosts;
      } else {
        throw Exception('Failed to load pinned posts');
      }
    } catch (error) {
      throw Exception('Failed to load pinned posts');
    }
  }

  Future<Map<String, dynamic>> deletePost(String postId) async {
    final String apiUrl = '$BASE_URL/api/posts/$postId/delete_post';

    try {
      var response = await http.delete(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else if (response.statusCode == 404) {
        final data = json.decode(response.body);
        return {'success': false, 'message': data['message']};
      } else {
        return {'success': false, 'message': 'Failed to delete post'};
      }
    } catch (error) {
      return {'success': false, 'message': 'Failed to delete post'};
    }
  }

  Future<Map<String, dynamic>> bumpPost(String postId) async {
    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/api/posts/$postId/BumpPost'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'message': data['message']};
      } else if (response.statusCode == 404) {
        return {'message': 'Post not found'};
      } else {
        return {'message': 'Failed to move post to the bottom'};
      }
    } catch (error) {
      print('Error bumping post: $error');
      return {'message': 'Failed to make the request'};
    }
  }

  Future<Map<String, dynamic>> sendOTP(String mobileNumber) async {
    final String apiUrl = '$BASE_URL/api/auth/contact';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.fields['mobileNumber'] = mobileNumber;

      var response = await request.send();

      if (response.statusCode == 200) {
        final data = await response.stream.bytesToString();
        return {'success': true, 'data': json.decode(data)};
      } else {
        final data = await response.stream.bytesToString();
        return {'success': false, 'message': json.decode(data)['message']};
      }
    } catch (error) {
      return {'success': false, 'message': 'Failed to send OTP'};
    }
  }

  Future<Map<String, dynamic>> verifyOTP(
      String mobileNumber, String userOTP) async {
    final String apiUrl = '$BASE_URL/api/auth/verify_otp';

    try {
      final response = await http.post(Uri.parse(apiUrl), body: {
        'mobileNumber': mobileNumber,
        'userOTP': userOTP,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        final data = json.decode(response.body);
        return {'success': false, 'message': data['message']};
      }
    } catch (error) {
      return {'success': false, 'message': 'Failed to verify OTP'};
    }
  }
}

class Post {
  final String? id;
  final String userId;
  final String profileImageUrl;
  final String userName;
  final String postMediaUrl;
  final String postMediaType;
  final String postAwsBucketKey;
  final String postContent;
  final bool isPinned;
  final bool isbumped;
  final bool isApproved;
  final bool underApproval;
  final String postCreated;
  DateTime? createdTime;
  final String flag;
  bool? isEmailVerified;
  DateTime? bumpTime;
  final String tag;

  // Constructor
  Post(
      {required this.id,
      required this.userId,
      required this.profileImageUrl,
      required this.userName,
      required this.postMediaUrl,
      required this.postMediaType,
      required this.postAwsBucketKey,
      required this.postContent,
      required this.isPinned,
      this.createdTime,
      this.isEmailVerified,
      required this.isbumped,
      required this.isApproved,
      required this.underApproval,
      required this.postCreated,
      required this.flag,
      this.bumpTime,
      required this.tag}) {
    try {
      createdTime =
          DateFormat("EEE MMM dd yyyy HH:mm:ss 'GMT'z").parse(postCreated);
    } catch (e) {
      print("Error parsing date: $e");
    }
  }

  // Factory method to create Post object from JSON
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'],
      tag: json['tag'] ?? "blank",
      userId: json['userId'] ?? "",
      profileImageUrl: json['profileImageUrl'] ?? "",
      userName: json['userName'] ?? "",
      postMediaUrl: json['postMediaUrl'] ?? "",
      postMediaType: json['postMediaType'] ?? "",
      postAwsBucketKey: json['postAwsBucketKey'] ?? "",
      postContent: json['postContent'] ?? "",
      isPinned: json['isPinned'] ?? false,
      isbumped: json['isbumped'] ?? false,
      isApproved: json['isApproved'] ?? false,
      underApproval: json['underApproval'] ?? false,
      postCreated: json['PostCreated'] ?? "",
      flag: json['flag'] ?? "",
      isEmailVerified: json['isEmailVerified'] ?? false,
      bumpTime:
          json['BumpTime'] != null ? DateTime.parse(json['BumpTime']) : null,
    );
  }
}
