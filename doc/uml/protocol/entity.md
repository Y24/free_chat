# entity

``` mermaid
classDiagram

 class BaseHeadEntity
 class ProtocolEntity
 class BaseBodyEntity
 class HeadEntity
 class BodyEntity

 BaseHeadEntity <|-- HeadEntity
 BaseBodyEntity <|-- BodyEntity
 ProtocolEntity o-- HeadEntity
 ProtocolEntity o-- BodyEntity
 class BaseHeadEntity{
    << abstract >>
    +dynamic id
    +dynamic type
    +String timestamp
    +fromJson(json)
    +json toJson()
 }
 class BaseBodyEntity{
    << abstract >>
    +String content
    +fromJson(json)
    +json toJson()
 }
 class ProtocolEntity{
     +HeadEntity head
     +BodyEntity body
     +fromJson(json)
     +json toJson()
 }
```