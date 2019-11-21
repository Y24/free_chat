# sender

``` mermaid
classDiagram
  class IProtocolSender
  class BaseProtocolSender
  IProtocolSender <|-- ProtocolSender
  BaseProtocolSender <|-- ProtocolSender
  class IProtocolSender {
  << interface >>
  +Future&lt;WebSocket&gt; init()
  +send()
  +Future&lt;void&gt; dispose()
  +get entity
  +void setEntity(entity)
 }
 class BaseProtocolSender {
 << abstract >>
  +static final String schema = 'wss'
  +static final domainName = 'y24.org.cn'
  +static final port = 2424
  - bool _connected
  +bool get connected
  +String get urlPrefix
  +WebSocket webSocket
  - Future&lt;void&gt; _clean()
  +Future&lt;WebSocket&gt; setUp()
  +Future&lt;void&gt; close()
 }
```