# FieldMApp CORE

Core Package that implements Module-Interfaces and the corresponding dependency injection logic, as well as Data-layer logic to connect and cache different datasources to the application.

## Architecture

### Data layer

Data layer implementation according to this [App-Architecture](https://codewithandrea.com/articles/flutter-app-architecture-riverpod-introduction/) which is a customized extension off [clean architecture by uncle bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html). 

![Data layer sketch](screenshots/data_layer.png)

**Overview**
- `api/auth`
    - Interface and mixin implementation for the universial auth-flow of the application. 
    - optional auth-credentials are cached using AES-encrypted device storage
- `api/data`
    -  Interface and mixin implementation for the universial Database-object handling. 
    - handels caching of Database-object, stored on device using AES-Encryption
- `api/media`
    -  Interface and mixin implementation for the universial File/Media-Upload handling. 
    - handels caching, data stored on device using AES-Encryption
- `api/provider`
    - provider/data source specific implementations of `auth`, `media` and `data` Interfaces
    - currently only Appwrite-Provider implemented
    - mixed provider implementations are possible (i.e. for CQRS)
    - provider implementation can also be done outside of this package

### Caching

**cache-Aside** 

https://codeahoy.com/2017/08/11/caching-strategies-and-how-to-choose-the-right-one/

## Code Generation

- generate code with `flutter packages pub run build_runner build --delete-conflicting-outputs`
- this is needed to create the Hive-Adapters for the cachinglayer, currently used by `api/data`, `api/media` and `api/auth`

