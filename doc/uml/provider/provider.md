# provider

``` mermaid
classDiagram

    class IProvider
    class BaseProvider
    class Provider
    IProvider <|-- Provider
    BaseProvider <|-- Provider
    class IProvider{
        << interface >>
        +get entity
        +void setEntity(entity)
        +Future&lt;bool&gt; init()
        +Future provide()
        +Future close()
    }
    class BaseProvider{
        << abstracgt >>
        +DataBse db
        +get dbName
        +get ownerName
        +Map&lt;String, List&lt;String&gt;&gt; get tables
    }

```
