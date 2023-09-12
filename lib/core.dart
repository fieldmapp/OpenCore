library core;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:open_core/src/api/auth/AuthService.extension.dart';
import 'package:open_core/src/api/auth/user_adapater.dart';
import 'package:open_core/core.dart';
import 'package:open_core/src/api/data/data_service.extension.dart';
import 'package:open_core/src/api/media/MediaService.extension.dart';
import 'package:appwrite/appwrite.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';

export 'src/exceptions/connection_exception.dart';
export 'src/exceptions/module_exception.dart';
export 'src/widgets/expandable_fab.widget.dart';
export 'src/widgets/info_container.widget.dart';
export 'src/api/data/data_adapater.dart';
export 'src/api/data/cache/data_cache_operation.dart';
export 'src/api/media/cache/file_cache_operation.dart';
export 'src/api/media/file_adapater.dart';

part 'src/module.model.dart';
part 'src/module.ui.dart';
part 'src/connectivity.service.dart';
part 'src/api/auth/api.auth.repository.dart';
part 'src/api/data/api.data.repository.dart';
part 'src/api/media/api.media.repository.dart';
part 'src/api/provider/appwrite/appwrite.auth.repository.dart';
part 'src/api/provider/appwrite/appwrite.base.dart';
part 'src/api/provider/appwrite/appwrite.data.repository.dart';
part 'src/api/provider/appwrite/appwrite.media.repository.dart';
