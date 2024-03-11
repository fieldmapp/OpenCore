class AppConstant {
  String projectId = "650836a449fc80a7029a";
  String endpoint = "http://localhost:80/v1";
  String databaseId = "fm_uploader_db_1";
  Set<String> collections = {"col1-doc", "col2-doc"};
  Set<String> buckets = {"data_mod_bucket"};
  bool selfSigned = true; // dev-stage only
}
