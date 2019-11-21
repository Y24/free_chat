# Handler

``` mermaid
classDiagram
  class IProtocolHandler
  class BaseProtocolHandler
  IProtocolHandler <|-- ProtocolHandler
  BaseProtocolHandler <|-- ProtocolHandler
  class IProtocolHandler {
  << interface >>
  +Future&lt;WebSocket&gt; init()
  +HandleResultEntity handle(webSocket)
  +Future&lt;void&gt; dispose()
  +get entity
  +void setEntity(entity)
 }
 class BaseProtocolHandler {
 << abstract >>
  - Database _db
  - bool _connected
  +static final dbPathPrefix = 'free_chat'
  +String get dbName
  +bool get connected
  - Future&lt;void&gt; cleanUp()
  +Future&lt;bool&gt; setUp()
  +Future&lt;void&gt; close()
 }
```