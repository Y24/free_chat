# service

``` mermaid
classDiagram
  class IProtocolService
  class ProtocolService
  IProtocolService <|-- ProtocolService
  class IProtocolService {
  << interface >>
  +Future&lt;WebSocket&gt; init()
  +send()
  +HandleResultEntity handle(webSocket)
  +Future&lt;void&gt; dispose(bool reserveWs)
  +get entity
  +void setEntity(entity)
 }
 class ProtocolService {
  +dynamic protocolEntity
  +final IProtocolSender protocolSender
  +final IProtocolHandler protocolHandler
  ...
 }
```