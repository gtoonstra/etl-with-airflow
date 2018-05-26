-- https://github.com/infinuendo/AdventureWorks
-- http://danlinstedt.com/allposts/datavaultcat/adventureworks-data-vault-ddl/

CREATE TABLE Hub_ProdSubCatID
(
    ProductSubcategoryID int  NOT NULL ,
    Hub_ProdSubCatID_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_ProdSubCatID_LDTS datetime  NOT NULL ,
    Hub_ProdSubCatID_RSRC nvarchar(18)  NULL ,
    CONSTRAINT PK_ProductSubcategory_ProductSubcategoryID PRIMARY KEY  CLUSTERED (Hub_ProdSubCatID_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_ProductSubcategoryID ON Hub_ProdSubCatID
(
    ProductSubcategoryID  ASC
)
go


CREATE TABLE Hub_ProdNum
(
    Hub_ProdNum_SQN      numeric(12) IDENTITY (1000,1) ,
    Hub_ProdNum_LDTS     datetime  NOT NULL ,
    Hub_ProdNum_RSRC     nvarchar(18)  NULL ,
    ProductNumber        nvarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    CONSTRAINT PK_Product_ProductID PRIMARY KEY  CLUSTERED (Hub_ProdNum_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_ProdNumID ON Hub_ProdNum
(
    ProductNumber         ASC
)
go


CREATE TABLE Hub_ProdCatID
(
    ProductCategoryID    int  NOT NULL ,
    Hub_ProdCatID_SQN    numeric(12) IDENTITY (1000,1) ,
    Hub_ProdCatID_LDTS   datetime  NOT NULL ,
    Hub_ProdCatID_RSRC   nvarchar(18)  NULL ,
    CONSTRAINT PK_ProductCategory_ProductCategoryID PRIMARY KEY  CLUSTERED (Hub_ProdCatID_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_ProductCategoryID ON Hub_ProdCatID
(
    ProductCategoryID     ASC
)
go


CREATE TABLE Lnk_ProdNum_ProdSubCatID
(
    Lnk_ProdNum_ProdSubCatID_LDTS datetime  NOT NULL ,
    Lnk_ProdNum_ProdSubCatID_RSRC nvarchar(18)  NULL ,
    Hub_ProdNum_SQN      numeric(12)  NULL ,
    Hub_ProdSubCatID_SQN numeric(12)  NOT NULL ,
    Lnk_ProdNum_ProdSubCatID_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_ProdCatID_SQN    numeric(12)  NOT NULL ,
    CONSTRAINT XPKLnk_ProdSubCatID_ProdCatID PRIMARY KEY  CLUSTERED (Lnk_ProdNum_ProdSubCatID_SQN ASC),
     FOREIGN KEY (Hub_ProdSubCatID_SQN) REFERENCES Hub_ProdSubCatID(Hub_ProdSubCatID_SQN),
 FOREIGN KEY (Hub_ProdNum_SQN) REFERENCES Hub_ProdNum(Hub_ProdNum_SQN),
 FOREIGN KEY (Hub_ProdCatID_SQN) REFERENCES Hub_ProdCatID(Hub_ProdCatID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Lnk_ProdSubCatID_ProdCatID ON Lnk_ProdNum_ProdSubCatID
(
    Hub_ProdNum_SQN       ASC,
    Hub_ProdSubCatID_SQN  ASC,
    Hub_ProdCatID_SQN     ASC
)
go


CREATE TABLE Sat_ProdSubCat
(
    Name                 nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Hub_ProdSubCatID_SQN numeric(12)  NOT NULL ,
    Sat_ProdSubCat_LDTS  datetime  NOT NULL ,
    Sat_ProdSubCat_RSRC  nvarchar(18)  NULL ,
    Sat_ProdSubCat_LEDTS datetime  NULL ,
    CONSTRAINT PK_SAT_ProductSubcategoryID PRIMARY KEY  CLUSTERED (Hub_ProdSubCatID_SQN ASC,Sat_ProdSubCat_LDTS ASC),
     FOREIGN KEY (Hub_ProdSubCatID_SQN) REFERENCES Hub_ProdSubCatID(Hub_ProdSubCatID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_ProductSubcategory_Name ON Sat_ProdSubCat
(
    Name                  ASC
)
go


CREATE TABLE Lnk_ProdSubCatID_ProdCatID
(
    Lnk_ProdSubCatID_ProdCatID_LDTS datetime  NOT NULL ,
    Lnk_ProdSubCatID_ProdCatID_RSRC nvarchar(18)  NULL ,
    Hub_ProdCatID_SQN    numeric(12)  NOT NULL ,
    Hub_ProdSubCatID_SQN numeric(12)  NOT NULL ,
    Lnk_ProdSubCatID_ProdCatID_SQN numeric(12) IDENTITY (1000,1) ,
    CONSTRAINT XPKLnk_ProdSubCatCatID PRIMARY KEY  CLUSTERED (Lnk_ProdSubCatID_ProdCatID_SQN ASC),
     FOREIGN KEY (Hub_ProdCatID_SQN) REFERENCES Hub_ProdCatID(Hub_ProdCatID_SQN),
 FOREIGN KEY (Hub_ProdSubCatID_SQN) REFERENCES Hub_ProdSubCatID(Hub_ProdSubCatID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Lnk_ProdSubCatID_ProdCatID ON Lnk_ProdSubCatID_ProdCatID
(
    Hub_ProdCatID_SQN     ASC,
    Hub_ProdSubCatID_SQN  ASC
)
go


CREATE TABLE Sat_ProdCat
(
    Name                 nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Hub_ProdCatID_SQN    numeric(12)  NOT NULL ,
    Sat_ProdCat_LDTS     datetime  NOT NULL ,
    Sat_ProdCat_RSRC     nvarchar(18)  NULL ,
    Sat_ProdCat_LEDTS    datetime  NULL ,
    CONSTRAINT PK_SAT_ProductCategoryID PRIMARY KEY  CLUSTERED (Hub_ProdCatID_SQN ASC,Sat_ProdCat_LDTS ASC),
     FOREIGN KEY (Hub_ProdCatID_SQN) REFERENCES Hub_ProdCatID(Hub_ProdCatID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_ProductCategory_Name ON Sat_ProdCat
(
    Name                  ASC
)
go


CREATE TABLE Hub_AddID
(
    AddressID            int  NOT NULL ,
    Hub_AddID_LDTS       datetime  NOT NULL ,
    Hub_AddID_RSRC       nvarchar(18)  NULL ,
    Hub_AddID_SQN        numeric(12) IDENTITY (1000,1) ,
    CONSTRAINT PK_Address_AddressID PRIMARY KEY  CLUSTERED (Hub_AddID_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_AddressID ON Hub_AddID
(
    AddressID             ASC
)
go


CREATE TABLE Hub_StProvID
(
    StateProvinceID      int  NOT NULL ,
    Hub_StProvID_LDTS    datetime  NOT NULL ,
    Hub_StProvID_RSRC    nvarchar(18)  NULL ,
    Hub_StProvID_SQN     numeric(12) IDENTITY (1000,1) ,
    CONSTRAINT PK_StateProvince_StateProvinceID PRIMARY KEY  CLUSTERED (Hub_StProvID_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_StateProvinceID ON Hub_StProvID
(
    StateProvinceID       ASC
)
go


CREATE TABLE Lnk_AddID_StProvID
(
    Lnk_AddID_StProvID_LDTS datetime  NOT NULL ,
    Lnk_AddID_StProvID_RSRC nvarchar(18)  NULL ,
    Lnk_AddID_StProvID_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_AddID_SQN        numeric(12)  NULL ,
    Hub_StProvID_SQN     numeric(12)  NULL ,
    CONSTRAINT XPKLnk_AddID_StProvID PRIMARY KEY  CLUSTERED (Lnk_AddID_StProvID_SQN ASC),
     FOREIGN KEY (Hub_AddID_SQN) REFERENCES Hub_AddID(Hub_AddID_SQN),
 FOREIGN KEY (Hub_StProvID_SQN) REFERENCES Hub_StProvID(Hub_StProvID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Lnk_AddID_StProvID ON Lnk_AddID_StProvID
(
    Hub_AddID_SQN         ASC,
    Hub_StProvID_SQN      ASC
)
go


CREATE TABLE Hub_DocNode
(
    DocumentNode         char(18)  NOT NULL ,
    Hub_DocNode_LDTS     datetime  NOT NULL ,
    Hub_DocNode_RSRC     nvarchar(18)  NULL ,
    Hub_DocNode_SQN      numeric(12) IDENTITY (1000,1) ,
    CONSTRAINT PK_Document_DocumentNode PRIMARY KEY  CLUSTERED (Hub_DocNode_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_DocumentNode ON Hub_DocNode
(
    DocumentNode          ASC
)
go


CREATE TABLE Lnk_ProdNum_DocNode
(
    Lnk_ProdNum_DocNode_LDTS datetime  NOT NULL ,
    Lnk_ProdNum_DocNode_RSRC nvarchar(18)  NULL ,
    Lnk_ProdNum_DocNode_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_DocNode_SQN      numeric(12)  NULL ,
    Hub_ProdNum_SQN      numeric(12)  NULL ,
    CONSTRAINT PK_ProductDocument_ProductID_DocumentNode PRIMARY KEY  CLUSTERED (Lnk_ProdNum_DocNode_SQN ASC),
     FOREIGN KEY (Hub_DocNode_SQN) REFERENCES Hub_DocNode(Hub_DocNode_SQN),
 FOREIGN KEY (Hub_ProdNum_SQN) REFERENCES Hub_ProdNum(Hub_ProdNum_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_ProductDocument ON Lnk_ProdNum_DocNode
(
    Hub_ProdNum_SQN       ASC,
    Hub_DocNode_SQN       ASC
)
go


CREATE TABLE Sat_Prod_Doc
(
    ModifiedDate         datetime  NOT NULL ,
    Sat_Prod_Doc_LDTS    datetime  NOT NULL ,
    Sat_Prod_Doc_LEDTS   datetime  NULL ,
    Sat_Prod_Doc_RSRC    nvarchar(18)  NULL ,
    Lnk_ProdNum_DocNode_SQN numeric(12)  NOT NULL ,
    CONSTRAINT PK_SAT_ProductDocumentID PRIMARY KEY  CLUSTERED (Lnk_ProdNum_DocNode_SQN ASC,Sat_Prod_Doc_LDTS ASC),
     FOREIGN KEY (Lnk_ProdNum_DocNode_SQN) REFERENCES Lnk_ProdNum_DocNode(Lnk_ProdNum_DocNode_SQN)
)
go


CREATE TABLE Hub_ShopCartItemID
(
    ShoppingCartItemID   int  NOT NULL ,
    Hub_ShopCartItemID_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_ShopCartItemID_LDTS datetime  NOT NULL ,
    Hub_ShopCartItemID_RSRC nvarchar(18)  NULL ,
    CONSTRAINT PK_ShoppingCartItem_ShoppingCartItemID PRIMARY KEY  CLUSTERED (Hub_ShopCartItemID_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_ShopCartItemID ON Hub_ShopCartItemID
(
    ShoppingCartItemID    ASC
)
go


CREATE TABLE Sat_ShopCartItem
(
    Quantity             int  NOT NULL ,
    DateCreated          datetime  NOT NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_ShopCartItem_LDTS datetime  NOT NULL ,
    Sat_ShopCartItem_RSRC nvarchar(18)  NULL ,
    Sat_ShopCartItem_LEDTS datetime  NULL ,
    Hub_ShopCartItemID_SQN numeric(12)  NOT NULL ,
    ShoppingCartID       nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    CONSTRAINT PK_SAT_ShoppingCartItemID PRIMARY KEY  CLUSTERED (Hub_ShopCartItemID_SQN ASC,Sat_ShopCartItem_LDTS ASC),
     FOREIGN KEY (Hub_ShopCartItemID_SQN) REFERENCES Hub_ShopCartItemID(Hub_ShopCartItemID_SQN)
)
go


CREATE TABLE Hub_SOrdNum
(
    Hub_SOrdNum_LDTS     datetime  NOT NULL ,
    Hub_SOrdNum_RSRC     nvarchar(18)  NULL ,
    Hub_SOrdNum_SQN      numeric(12) IDENTITY (1000,1) ,
    SalesOrderNumber     nvarchar(25)  NOT NULL ,
    CONSTRAINT PK_SalesOrderHeader_SalesOrderID PRIMARY KEY  CLUSTERED (Hub_SOrdNum_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_SalesOrderHeaderID ON Hub_SOrdNum
(
    SalesOrderNumber      ASC
)
go


CREATE TABLE Hub_SRsnID
(
    SalesReasonID        int  NOT NULL ,
    Hub_SRsnID_LDTS      datetime  NOT NULL ,
    Hub_SRsnID_RSRC      nvarchar(18)  NULL ,
    Hub_SRsnID_SQN       numeric(12) IDENTITY (1000,1) ,
    CONSTRAINT PK_SalesReason_SalesReasonID PRIMARY KEY  CLUSTERED (Hub_SRsnID_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_SalesReasonID ON Hub_SRsnID
(
    SalesReasonID         ASC
)
go


CREATE TABLE Lnk_SOrdNum_SRsnID
(
    Lnk_SOrdNum_SRsnID_LDTS datetime  NOT NULL ,
    Lnk_SOrdNum_SRsnID_RSRC nvarchar(18)  NULL ,
    Lnk_SOrdNum_SRsnID_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_SOrdNum_SQN      numeric(12)  NULL ,
    Hub_SRsnID_SQN       numeric(12)  NULL ,
    CONSTRAINT PK_SalesOrderHeaderSalesReason PRIMARY KEY  CLUSTERED (Lnk_SOrdNum_SRsnID_SQN ASC),
     FOREIGN KEY (Hub_SOrdNum_SQN) REFERENCES Hub_SOrdNum(Hub_SOrdNum_SQN),
 FOREIGN KEY (Hub_SRsnID_SQN) REFERENCES Hub_SRsnID(Hub_SRsnID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_SalesOrderHeaderSalesReason ON Lnk_SOrdNum_SRsnID
(
    Hub_SOrdNum_SQN       ASC,
    Hub_SRsnID_SQN        ASC
)
go


CREATE TABLE Sat_SOrdNum_SRsnID
(
    ModifiedDate         datetime  NOT NULL ,
    Sat_SOrdNum_SRsnID_LDTS datetime  NOT NULL ,
    Sat_SOrdNum_SRsnID_LEDTS datetime  NULL ,
    Sat_SOrdNum_SRsnID_RSRC nvarchar(18)  NULL ,
    Lnk_SOrdNum_SRsnID_SQN numeric(12)  NOT NULL ,
    CONSTRAINT PK_SalesOrderHeaderSalesReason_SalesOrderID_SalesReasonID PRIMARY KEY  CLUSTERED (Lnk_SOrdNum_SRsnID_SQN ASC,Sat_SOrdNum_SRsnID_LDTS ASC),
     FOREIGN KEY (Lnk_SOrdNum_SRsnID_SQN) REFERENCES Lnk_SOrdNum_SRsnID(Lnk_SOrdNum_SRsnID_SQN)
)
go

-- I WAS HERE
CREATE TABLE Lnk_ProdNum_ShopCartItemID
(
    Lnk_ProdNum_ShopCartItemID_SQN numeric(12) IDENTITY (1000,1) ,
    Lnk_ProdNum_ShopCartItemID_LDTS datetime  NOT NULL ,
    Lnk_ProdNum_ShopCartItemID_RSRC nvarchar(18)  NULL ,
    Hub_ShopCartItemID_SQN numeric(12)  NULL ,
    Hub_ProdNum_SQN      numeric(12)  NULL ,
    CONSTRAINT PK_Lnk_ProdNum_ShopCartItemID PRIMARY KEY  CLUSTERED (Lnk_ProdNum_ShopCartItemID_SQN ASC),
     FOREIGN KEY (Hub_ShopCartItemID_SQN) REFERENCES Hub_ShopCartItemID(Hub_ShopCartItemID_SQN),
 FOREIGN KEY (Hub_ProdNum_SQN) REFERENCES Hub_ProdNum(Hub_ProdNum_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Lnk_ProdNum_ShopCartItemID ON Lnk_ProdNum_ShopCartItemID
(
    Hub_ShopCartItemID_SQN  ASC,
    Hub_ProdNum_SQN       ASC
)
go


CREATE TABLE Hub_ProdPhotoID
(
    ProductPhotoID       int  NOT NULL ,
    Hub_ProdPhotoID_SQN  numeric(12) IDENTITY (1000,1) ,
    Hub_ProdPhotoID_LDTS datetime  NOT NULL ,
    Hub_ProdPhotoID_RSRC nvarchar(18)  NULL ,
    CONSTRAINT PK_ProductPhoto_ProductPhotoID PRIMARY KEY  CLUSTERED (Hub_ProdPhotoID_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_ProdPhotoID ON Hub_ProdPhotoID
(
    ProductPhotoID        ASC
)
go


CREATE TABLE Lnk_ProdNum_ProdPhotoID
(
    Lnk_ProdNum_ProdPhotoID_SQN numeric(12) IDENTITY (1000,1) ,
    Lnk_ProdNum_ProdPhotoID_LDTS datetime  NOT NULL ,
    Lnk_ProdNum_ProdPhotoID_RSRC nvarchar(18)  NULL ,
    Hub_ProdNum_SQN      numeric(12)  NULL ,
    Hub_ProdPhotoID_SQN  numeric(12)  NULL ,
    CONSTRAINT PK_ProductProductPhoto_ProductID_ProductPhotoID PRIMARY KEY  NONCLUSTERED (Lnk_ProdNum_ProdPhotoID_SQN ASC),
     FOREIGN KEY (Hub_ProdNum_SQN) REFERENCES Hub_ProdNum(Hub_ProdNum_SQN),
 FOREIGN KEY (Hub_ProdPhotoID_SQN) REFERENCES Hub_ProdPhotoID(Hub_ProdPhotoID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Lnk_ProdNum_ProdPhotoID ON Lnk_ProdNum_ProdPhotoID
(
    Hub_ProdNum_SQN       ASC,
    Hub_ProdPhotoID_SQN   ASC
)
go


CREATE TABLE Sat_Prod_ProdPhoto
(
    [Primary]              bit  NOT NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_ProdNum_ProdPhotoID_LDTS datetime  NOT NULL ,
    Sat_ProdNum_ProdPhotoID_RSRC nvarchar(18)  NULL ,
    Sat_ProdNum_ProdPhotoID_LEDTS datetime  NULL ,
    Lnk_ProdNum_ProdPhotoID_SQN numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_Prod_ProdPhoto PRIMARY KEY  NONCLUSTERED (Lnk_ProdNum_ProdPhotoID_SQN ASC,Sat_ProdNum_ProdPhotoID_LDTS ASC),
     FOREIGN KEY (Lnk_ProdNum_ProdPhotoID_SQN) REFERENCES Lnk_ProdNum_ProdPhotoID(Lnk_ProdNum_ProdPhotoID_SQN)
)
go


CREATE TABLE Sat_ProdPhoto
(
    ThumbNailPhoto       varbinary(max)  NULL ,
    ThumbnailPhotoFileName nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL ,
    LargePhoto           varbinary(max)  NULL ,
    LargePhotoFileName   nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_ProdPhoto_LDTS   datetime  NOT NULL ,
    Sat_ProdPhoto_RSRC   nvarchar(18)  NULL ,
    Sat_ProdPhoto_LEDTS  datetime  NULL ,
    Hub_ProdPhotoID_SQN  numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_ProdPhoto PRIMARY KEY  CLUSTERED (Hub_ProdPhotoID_SQN ASC,Sat_ProdPhoto_LDTS ASC),
     FOREIGN KEY (Hub_ProdPhotoID_SQN) REFERENCES Hub_ProdPhotoID(Hub_ProdPhotoID_SQN)
)
go


CREATE TABLE Hub_SOfrID
(
    SpecialOfferID       int  NOT NULL ,
    Hub_SOfrID_LDTS      datetime  NOT NULL ,
    Hub_SOfrID_RSRC      nvarchar(18)  NULL ,
    Hub_SOfrID_SQN       numeric(12) IDENTITY (1000,1) ,
    CONSTRAINT PK_SpecialOffer_SpecialOfferID PRIMARY KEY  CLUSTERED (Hub_SOfrID_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_SpecialOfferID ON Hub_SOfrID
(
    SpecialOfferID        ASC
)
go


CREATE TABLE Sat_SOfr
(
    Description          nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    DiscountPct          smallmoney  NOT NULL ,
    Type                 nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    Category             nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    StartDate            datetime  NOT NULL ,
    EndDate              datetime  NOT NULL ,
    MinQty               int  NOT NULL ,
    MaxQty               int  NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_SOfr_LDTS        datetime  NOT NULL ,
    Sat_SOfr_LEDTS       datetime  NULL ,
    Sat_SOfr_RSRC        nvarchar(18)  NULL ,
    Hub_SOfrID_SQN       numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_SOfr PRIMARY KEY  CLUSTERED (Hub_SOfrID_SQN ASC,Sat_SOfr_LDTS ASC),
     FOREIGN KEY (Hub_SOfrID_SQN) REFERENCES Hub_SOfrID(Hub_SOfrID_SQN)
)
go


CREATE TABLE Lnk_ProdNum_SOrdNum_SOfrID
(
    Lnk_ProdNum_SOrdNum_SOfrID_LDTS datetime  NOT NULL ,
    Lnk_ProdNum_SOrdNum_SOfrID_RSRC nvarchar(18)  NULL ,
    Lnk_ProdNum_SOrdNum_SOfrID_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_ProdNum_SQN      numeric(12)  NULL ,
    Hub_SOfrID_SQN       numeric(12)  NULL ,
    SalesOrderDetailID   int  NOT NULL ,
    Hub_SOrdNum_SQN      numeric(12)  NULL ,
    CONSTRAINT PK_SpecialOfferProduct_SpecialOfferID_ProductID PRIMARY KEY  CLUSTERED (Lnk_ProdNum_SOrdNum_SOfrID_SQN ASC),
     FOREIGN KEY (Hub_ProdNum_SQN) REFERENCES Hub_ProdNum(Hub_ProdNum_SQN),
 FOREIGN KEY (Hub_SOfrID_SQN) REFERENCES Hub_SOfrID(Hub_SOfrID_SQN),
 FOREIGN KEY (Hub_SOrdNum_SQN) REFERENCES Hub_SOrdNum(Hub_SOrdNum_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_SpecialOfferProduct ON Lnk_ProdNum_SOrdNum_SOfrID
(
    Hub_ProdNum_SQN       ASC,
    Hub_SOfrID_SQN        ASC,
    SalesOrderDetailID    ASC,
    Hub_SOrdNum_SQN       ASC
)
go


CREATE TABLE Sat_SOrdDet
(
    CarrierTrackingNumber nvarchar(25)  NULL ,
    OrderQty             smallint  NOT NULL ,
    UnitPrice            money  NOT NULL ,
    UnitPriceDiscount    money  NOT NULL ,
    LineTotal            numeric(38,6)  NOT NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_SOrdDet_LDTS     datetime  NOT NULL ,
    Sat_SOrdDet_LEDTS    datetime  NULL ,
    Sat_SOrdDet_RSRC     nvarchar(18)  NULL ,
    Lnk_ProdNum_SOrdID_SOfrID_SQN numeric(12)  NOT NULL ,
    CONSTRAINT PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID PRIMARY KEY  CLUSTERED (Lnk_ProdNum_SOrdID_SOfrID_SQN ASC,Sat_SOrdDet_LDTS ASC),
     FOREIGN KEY (Lnk_ProdNum_SOrdID_SOfrID_SQN) REFERENCES Lnk_ProdNum_SOrdNum_SOfrID(Lnk_ProdNum_SOrdNum_SOfrID_SQN)
)
go


CREATE TABLE Hub_LocID
(
    LocationID           smallint  NOT NULL ,
    Hub_LocID_LDTS       datetime  NOT NULL ,
    Hub_LocID_RSRC       nvarchar(18)  NULL ,
    Hub_LocID_SQN        numeric(12) IDENTITY (1000,1) ,
    CONSTRAINT PK_Location_LocationID PRIMARY KEY  CLUSTERED (Hub_LocID_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_LocationID ON Hub_LocID
(
    LocationID            ASC
)
go


CREATE TABLE Sat_Loc
(
    Name                 nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    CostRate             smallmoney  NOT NULL ,
    Availability         decimal(8,2)  NOT NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_Loc_LDTS         datetime  NOT NULL ,
    Sat_Loc_LEDTS        datetime  NULL ,
    Sat_Loc_RSRC         nvarchar(18)  NULL ,
    Hub_LocID_SQN        numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_Loc PRIMARY KEY  CLUSTERED (Hub_LocID_SQN ASC,Sat_Loc_LDTS ASC),
     FOREIGN KEY (Hub_LocID_SQN) REFERENCES Hub_LocID(Hub_LocID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Location_Name ON Sat_Loc
(
    Name                  ASC
)
go


CREATE TABLE Sat_ProdNum_SOrdNum_SOfrID
(
    ModifiedDate         datetime  NOT NULL ,
    Sat_ProdNum_SOrdNum_SOfrID_LDTS datetime  NOT NULL ,
    Sat_ProdNum_SOrdNum_SOfrID_LEDTS datetime  NULL ,
    Sat_ProdNum_SOrdNum_SOfrID_RSRC nvarchar(18)  NULL ,
    Lnk_ProdNum_SOrdNum_SOfrID_SQN numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_ProdNum_SOrdNum_SOfrID PRIMARY KEY  CLUSTERED (Lnk_ProdNum_SOrdNum_SOfrID_SQN ASC,Sat_ProdNum_SOrdNum_SOfrID_LDTS ASC),
     FOREIGN KEY (Lnk_ProdNum_SOrdNum_SOfrID_SQN) REFERENCES Lnk_ProdNum_SOrdNum_SOfrID(Lnk_ProdNum_SOrdNum_SOfrID_SQN)
)
go


CREATE TABLE Hub_TransID
(
    TransactionID        int  NOT NULL ,
    Hub_TransID_SQN      numeric(12) IDENTITY (1000,1) ,
    Hub_TransID_LDTS     datetime  NOT NULL ,
    Hub_TransID_RSRC     nvarchar(18)  NULL ,
    CONSTRAINT PK_TransactionHistory_TransactionID PRIMARY KEY  CLUSTERED (Hub_TransID_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_TransID ON Hub_TransID
(
    TransactionID         ASC
)
go


CREATE TABLE Sat_TransHist
(
    TransactionID        int IDENTITY (100000,1) ,
    ReferenceOrderID     int  NOT NULL ,
    ReferenceOrderLineID int  NOT NULL ,
    TransactionDate      datetime  NOT NULL ,
    TransactionType      nchar(1) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    Quantity             int  NOT NULL ,
    ActualCost           money  NOT NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_TransHist_LDTS   datetime  NOT NULL ,
    Sat_TransHist_RSRC   nvarchar(18)  NULL ,
    Hub_TransID_SQN      numeric(12)  NOT NULL ,
    Sat_TransHist_LEDTS  datetime  NULL ,
    CONSTRAINT PK_Sat_TransHist PRIMARY KEY  CLUSTERED (Hub_TransID_SQN ASC,Sat_TransHist_LDTS ASC),
     FOREIGN KEY (Hub_TransID_SQN) REFERENCES Hub_TransID(Hub_TransID_SQN)
)
go


CREATE NONCLUSTERED INDEX IX_TransactionHistory_ReferenceOrderID_ReferenceOrderLineID ON Sat_TransHist
(
    ReferenceOrderID      ASC,
    ReferenceOrderLineID  ASC
)
go


CREATE TABLE Sat_ProdListPriceHist
(
    StartDate            datetime  NOT NULL ,
    EndDate              datetime  NULL ,
    ListPrice            money  NOT NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_ProdListPriceHist_LDTS datetime  NOT NULL ,
    Sat_ProdListPriceHist_LEDTS datetime  NULL ,
    Sat_ProdListPriceHist_RSRC nvarchar(18)  NULL ,
    Hub_ProdNum_SQN      numeric(12)  NOT NULL ,
    CONSTRAINT PK_ProductListPriceHistory_ProductID_StartDate PRIMARY KEY  CLUSTERED (Hub_ProdNum_SQN ASC,Sat_ProdListPriceHist_LDTS ASC),
     FOREIGN KEY (Hub_ProdNum_SQN) REFERENCES Hub_ProdNum(Hub_ProdNum_SQN)
)
go


CREATE TABLE Sat_ProdCostHist
(
    StartDate            datetime  NOT NULL ,
    EndDate              datetime  NULL ,
    StandardCost         money  NOT NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_ProdCostHist_LDTS datetime  NOT NULL ,
    Sat_ProdCostHist_LEDTS datetime  NULL ,
    Sat_ProdCostHist_RSRC nvarchar(18)  NULL ,
    Hub_ProdNum_SQN      numeric(12)  NOT NULL ,
    CONSTRAINT PK_ProductCostHistory_ProductID_StartDate PRIMARY KEY  CLUSTERED (Hub_ProdNum_SQN ASC,Sat_ProdCostHist_LDTS ASC),
     FOREIGN KEY (Hub_ProdNum_SQN) REFERENCES Hub_ProdNum(Hub_ProdNum_SQN)
)
go


CREATE TABLE Sat_ProdRev
(
    ProductReviewID      int IDENTITY (1,1) ,
    ReviewerName         nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    ReviewDate           datetime  NOT NULL ,
    EmailAddress         nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    Rating               int  NOT NULL ,
    Comments             nvarchar(3850) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_ProdRev_LDTS     datetime  NOT NULL ,
    Sat_ProdRev_LEDTS    datetime  NULL ,
    Sat_ProdRev_RSRC     nvarchar(18)  NULL ,
    Hub_ProdNum_SQN      numeric(12)  NOT NULL ,
    CONSTRAINT PK_ProductReview_ProductReviewID PRIMARY KEY  CLUSTERED (Hub_ProdNum_SQN ASC,Sat_ProdRev_LDTS ASC),
     FOREIGN KEY (Hub_ProdNum_SQN) REFERENCES Hub_ProdNum(Hub_ProdNum_SQN)
)
go


CREATE NONCLUSTERED INDEX IX_ProductReview_ProductID_Name ON Sat_ProdRev
(
    ReviewerName          ASC
)
INCLUDE(Comments)
go


CREATE TABLE Hub_Wrk_Ord
(
    WorkOrderID          int  NOT NULL ,
    Hub_WOID_LDTS        datetime  NOT NULL ,
    Hub_WOID_RSRC        nvarchar(18)  NULL ,
    Hub_WOID_SQN         numeric(12) IDENTITY (1000,1) ,
    CONSTRAINT PK_WorkOrder_WorkOrderID PRIMARY KEY  CLUSTERED (Hub_WOID_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_WorkOrderID ON Hub_Wrk_Ord
(
    WorkOrderID           ASC
)
go


CREATE TABLE Sat_Wrk_Ord
(
    OrderQty             int  NOT NULL ,
    StockedQty           int  NOT NULL ,
    ScrappedQty          smallint  NOT NULL ,
    StartDate            datetime  NOT NULL ,
    EndDate              datetime  NULL ,
    DueDate              datetime  NOT NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_WOID_LDTS        datetime  NOT NULL ,
    Sat_WOID_LEDTS       datetime  NULL ,
    Sat_WOID_RSRC        nvarchar(18)  NULL ,
    Hub_WOID_SQN         numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_Wrk_Ord PRIMARY KEY  CLUSTERED (Hub_WOID_SQN ASC,Sat_WOID_LDTS ASC),
     FOREIGN KEY (Hub_WOID_SQN) REFERENCES Hub_Wrk_Ord(Hub_WOID_SQN)
)
go


CREATE TABLE Hub_EmpID
(
    EmployeeID           integer  NOT NULL ,
    Hub_EmpID_LDTS       datetime  NOT NULL ,
    Hub_EmpID_RSRC       nvarchar(18)  NULL ,
    Hub_EmpID_SQN        numeric(12) IDENTITY (1000,1) ,
    CONSTRAINT PK_Employee_BusinessEntityID PRIMARY KEY  CLUSTERED (Hub_EmpID_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_EmployeeID ON Hub_EmpID
(
    EmployeeID            ASC
)
go


CREATE TABLE Sat_EmpPayHist
(
    RateChangeDate       datetime  NOT NULL ,
    Rate                 money  NOT NULL ,
    PayFrequency         tinyint  NOT NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_EmpPayHist_LDTS  datetime  NOT NULL ,
    Sat_EmpPayHist_LEDTS datetime  NULL ,
    Sat_EmpPayHist_RSRC  nvarchar(18)  NULL ,
    Hub_EmpID_SQN        numeric(12)  NOT NULL ,
    CONSTRAINT PK_EmployeePayHistory_BusinessEntityID_RateChangeDate PRIMARY KEY  CLUSTERED (Hub_EmpID_SQN ASC,Sat_EmpPayHist_LDTS ASC),
     FOREIGN KEY (Hub_EmpID_SQN) REFERENCES Hub_EmpID(Hub_EmpID_SQN)
)
go


CREATE TABLE ErrorLog
(
    ErrorLogID           int IDENTITY (1,1) ,
    ErrorTime            datetime  NOT NULL ,
    UserName             nvarchar(128) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    ErrorNumber          int  NOT NULL ,
    ErrorSeverity        int  NULL ,
    ErrorState           int  NULL ,
    ErrorProcedure       nvarchar(126) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL ,
    ErrorLine            int  NULL ,
    ErrorMessage         nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    CONSTRAINT PK_ErrorLog_ErrorLogID PRIMARY KEY  CLUSTERED (ErrorLogID ASC)
)
go


CREATE TABLE DatabaseLog
(
    DatabaseLogID        int IDENTITY (1,1) ,
    PostTime             datetime  NOT NULL ,
    DatabaseUser         nvarchar(128) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    Event                nvarchar(128) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    [Schema]               nvarchar(128) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL ,
    Object               nvarchar(128) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL ,
    TSQL                 nvarchar(max) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    XmlEvent             xml  NOT NULL ,
    CONSTRAINT PK_DatabaseLog_DatabaseLogID PRIMARY KEY  NONCLUSTERED (DatabaseLogID ASC)
)
TEXTIMAGE_ON [PRIMARY]
go


CREATE TABLE TransactionHistoryArchive
(
    TransactionID        int  NOT NULL ,
    ProductID            int  NOT NULL ,
    ReferenceOrderID     int  NOT NULL ,
    ReferenceOrderLineID int  NOT NULL ,
    TransactionDate      datetime  NOT NULL ,
    TransactionType      nchar(1) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    Quantity             int  NOT NULL ,
    ActualCost           money  NOT NULL ,
    ModifiedDate         datetime  NOT NULL ,
    CONSTRAINT PK_TransactionHistoryArchive_TransactionID PRIMARY KEY  CLUSTERED (TransactionID ASC)
)
go


CREATE NONCLUSTERED INDEX IX_TransactionHistoryArchive_ProductID ON TransactionHistoryArchive
(
    ProductID             ASC
)
go


CREATE NONCLUSTERED INDEX IX_TransactionHistoryArchive_ReferenceOrderID_ReferenceOrderLine ON TransactionHistoryArchive
(
    ReferenceOrderID      ASC,
    ReferenceOrderLineID  ASC
)
go


CREATE TABLE AWBuildVersion
(
    SystemInformationID  tinyint IDENTITY (1,1) ,
    Database_Version     nvarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    VersionDate          datetime  NOT NULL ,
    ModifiedDate         datetime  NOT NULL ,
    CONSTRAINT PK_AWBuildVersion_SystemInformationID PRIMARY KEY  CLUSTERED (SystemInformationID ASC)
)
go


CREATE TABLE Lnk_ProdNum_TransID
(
    Lnk_ProdNum_TransID_LDTS datetime  NOT NULL ,
    Lnk_ProdNum_TransID_RSRC nvarchar(18)  NULL ,
    Hub_TransID_SQN      numeric(12)  NULL ,
    Hub_ProdNum_SQN      numeric(12)  NULL ,
    Lnk_ProdNum_TransID_SQN numeric(12) IDENTITY (1000,1) ,
    CONSTRAINT PK_Lnk_ProdNum_TransID PRIMARY KEY  CLUSTERED (Lnk_ProdNum_TransID_SQN ASC),
     FOREIGN KEY (Hub_TransID_SQN) REFERENCES Hub_TransID(Hub_TransID_SQN),
 FOREIGN KEY (Hub_ProdNum_SQN) REFERENCES Hub_ProdNum(Hub_ProdNum_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_TransactionHistory ON Lnk_ProdNum_TransID
(
    Hub_TransID_SQN       ASC,
    Hub_ProdNum_SQN       ASC
)
go


CREATE TABLE Hub_CCID
(
    CreditCardID         int  NOT NULL ,
    Hub_CCID_LDTS        datetime  NOT NULL ,
    Hub_CCID_RSRC        nvarchar(18)  NULL ,
    Hub_CCID_SQN         numeric(12) IDENTITY (1000,1) ,
    CONSTRAINT PK_CreditCard_CreditCardID PRIMARY KEY  CLUSTERED (Hub_CCID_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_CreditCardID ON Hub_CCID
(
    CreditCardID          ASC
)
go


CREATE TABLE Sat_CC
(
    CardType             nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    CardNumber           nvarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    ExpMonth             tinyint  NOT NULL ,
    ExpYear              smallint  NOT NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_CC_LDTS          datetime  NOT NULL ,
    Sat_CC_LEDTS         datetime  NULL ,
    Sat_CC_RSRC          nvarchar(18)  NULL ,
    Hub_CCID_SQN         numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_CC PRIMARY KEY  CLUSTERED (Hub_CCID_SQN ASC,Sat_CC_LDTS ASC),
     FOREIGN KEY (Hub_CCID_SQN) REFERENCES Hub_CCID(Hub_CCID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_CreditCard_CardNumber ON Sat_CC
(
    CardNumber            ASC
)
go


CREATE TABLE Hub_JobCandID
(
    JobCandidateID       int  NOT NULL ,
    Hub_JobCandID_LDTS   datetime  NOT NULL ,
    Hub_JobCandID_RSRC   nvarchar(18)  NULL ,
    Hub_JobCandID_SQN    numeric(12) IDENTITY (1000,1) ,
    CONSTRAINT PK_JobCandidate_JobCandidateID PRIMARY KEY  CLUSTERED (Hub_JobCandID_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_JobCandidateID ON Hub_JobCandID
(
    JobCandidateID        ASC
)
go


CREATE TABLE Sat_JobCand
(
    Resume               xml  NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_JobCand_LDTS     datetime  NOT NULL ,
    Sat_JobCand_LEDTS    datetime  NULL ,
    Sat_JobCand_RSRC     nvarchar(18)  NULL ,
    Hub_JobCandID_SQN    numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_JobCand PRIMARY KEY  CLUSTERED (Hub_JobCandID_SQN ASC,Sat_JobCand_LDTS ASC),
     FOREIGN KEY (Hub_JobCandID_SQN) REFERENCES Hub_JobCandID(Hub_JobCandID_SQN)
)
go


CREATE TABLE Lnk_WOID_LocID
(
    Lnk_WOID_LocID_WOOpSeqID_LDTS datetime  NOT NULL ,
    Lnk_WOID_LocID_WOOpSeqID_RSRC nvarchar(18)  NULL ,
    Lnk_WOID_LocID_WOOpSeqID_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_WOID_SQN         numeric(12)  NULL ,
    Hub_LocID_SQN        numeric(12)  NULL ,
    Oper_Seq             smallint  NOT NULL ,
    CONSTRAINT PK_WorkOrderRouting PRIMARY KEY  CLUSTERED (Lnk_WOID_LocID_WOOpSeqID_SQN ASC),
     FOREIGN KEY (Hub_WOID_SQN) REFERENCES Hub_Wrk_Ord(Hub_WOID_SQN),
 FOREIGN KEY (Hub_LocID_SQN) REFERENCES Hub_LocID(Hub_LocID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_WorkOrderRouting ON Lnk_WOID_LocID
(
    Hub_WOID_SQN          ASC,
    Hub_LocID_SQN         ASC,
    Oper_Seq              ASC
)
go


CREATE TABLE Sat_WOID_LocID
(
    ScheduledStartDate   datetime  NOT NULL ,
    ScheduledEndDate     datetime  NOT NULL ,
    ActualStartDate      datetime  NULL ,
    ActualEndDate        datetime  NULL ,
    ActualResourceHrs    decimal(9,4)  NULL ,
    PlannedCost          money  NOT NULL ,
    ActualCost           money  NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_WOID_LocID_LDTS  datetime  NOT NULL ,
    Sat_WOID_LocID_LEDTS datetime  NULL ,
    Sat_WOID_LocID_RSRC  nvarchar(18)  NULL ,
    Lnk_WOID_LocID_SQN   numeric(12)  NOT NULL ,
    CONSTRAINT PK_WorkOrderRouting_WorkOrderID_ProductID_OperationSequence PRIMARY KEY  CLUSTERED (Lnk_WOID_LocID_SQN ASC,Sat_WOID_LocID_LDTS ASC),
     FOREIGN KEY (Lnk_WOID_LocID_SQN) REFERENCES Lnk_WOID_LocID(Lnk_WOID_LocID_WOOpSeqID_SQN)
)
go


CREATE TABLE Hub_PersID
(
    PersonID             integer  NOT NULL ,
    Hub_PersID_LDTS      datetime  NOT NULL ,
    Hub_PersID_RSRC      nvarchar(18)  NULL ,
    Hub_PersID_SQN       numeric(12) IDENTITY (1000,1) ,
    CONSTRAINT PK_Person_BusinessEntityID PRIMARY KEY  CLUSTERED (Hub_PersID_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_PersonID ON Hub_PersID
(
    PersonID              ASC
)
go


CREATE TABLE Hub_BusEntID
(
    BusinessEntityID     int  NOT NULL ,
    Hub_BusEntID_LDTS    datetime  NOT NULL ,
    Hub_BusEntID_RSRC    nvarchar(18)  NULL ,
    Hub_BusEntID_SQN     numeric(12) IDENTITY (1000,1) ,
    CONSTRAINT PK_BusinessEntity_BusinessEntityID PRIMARY KEY  CLUSTERED (Hub_BusEntID_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_BusinessEntityID ON Hub_BusEntID
(
    BusinessEntityID      ASC
)
go


CREATE TABLE Lnk_PersID_BusEntID
(
    Lnk_PersID_BusEntID_LDTS datetime  NOT NULL ,
    Lnk_PersID_BusEntID_RSRC nvarchar(18)  NULL ,
    Lnk_PersID_BusEntID_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_PersID_SQN       numeric(12)  NULL ,
    Hub_BusEntID_SQN     numeric(12)  NULL ,
    CONSTRAINT XPKLnk_PersID_BEID PRIMARY KEY  CLUSTERED (Lnk_PersID_BusEntID_SQN ASC),
     FOREIGN KEY (Hub_PersID_SQN) REFERENCES Hub_PersID(Hub_PersID_SQN),
 FOREIGN KEY (Hub_BusEntID_SQN) REFERENCES Hub_BusEntID(Hub_BusEntID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Lnk_PersID_BEID ON Lnk_PersID_BusEntID
(
    Hub_PersID_SQN        ASC,
    Hub_BusEntID_SQN      ASC
)
go


CREATE TABLE Hub_ScrapID
(
    ScrapReasonID        smallint  NOT NULL ,
    Hub_ScrapID_LDTS     datetime  NOT NULL ,
    Hub_ScrapID_SQN      numeric(12) IDENTITY (1000,1) ,
    Hub_ScrapID_RSRC     nvarchar(18)  NULL ,
    CONSTRAINT PK_ScrapReason_ScrapReasonID PRIMARY KEY  CLUSTERED (Hub_ScrapID_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_ScrapReasonID ON Hub_ScrapID
(
    ScrapReasonID         ASC
)
go


CREATE TABLE Lnk_Wrk_Ord_ScrapID
(
    Lnk_WOID_ScrapID_LDTS datetime  NOT NULL ,
    Lnk_WOID_ScrapID_RSRC nvarchar(18)  NULL ,
    Lnk_WOID_ScrapID_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_WOID_SQN         numeric(12)  NOT NULL ,
    Hub_ScrapID_SQN      numeric(12)  NOT NULL ,
    CONSTRAINT PK_Lnk_Wrk_Ord_ScrapID PRIMARY KEY  CLUSTERED (Lnk_WOID_ScrapID_SQN ASC),
     FOREIGN KEY (Hub_WOID_SQN) REFERENCES Hub_Wrk_Ord(Hub_WOID_SQN),
 FOREIGN KEY (Hub_ScrapID_SQN) REFERENCES Hub_ScrapID(Hub_ScrapID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_ScrapReason ON Lnk_Wrk_Ord_ScrapID
(
    Hub_WOID_SQN          ASC,
    Hub_ScrapID_SQN       ASC
)
go


CREATE TABLE Lnk_SOrdNum_CCID
(
    Lnk_SOrdNum_CCID_LDTS datetime  NOT NULL ,
    Lnk_SOrdNum_CCID_RSRC nvarchar(18)  NULL ,
    Lnk_SOrdNum_CCID_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_SOrdNum_SQN      numeric(12)  NULL ,
    Hub_CCID_SQN         numeric(12)  NULL ,
    CONSTRAINT XPKLnk_SOrdNum_Add PRIMARY KEY  CLUSTERED (Lnk_SOrdNum_CCID_SQN ASC),
     FOREIGN KEY (Hub_SOrdNum_SQN) REFERENCES Hub_SOrdNum(Hub_SOrdNum_SQN),
 FOREIGN KEY (Hub_CCID_SQN) REFERENCES Hub_CCID(Hub_CCID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Lnk_SOrdNum_Add ON Lnk_SOrdNum_CCID
(
    Hub_SOrdNum_SQN       ASC,
    Hub_CCID_SQN          ASC
)
go


CREATE TABLE Sat_Scrap
(
    Name                 nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_Scrap_LDTS       datetime  NOT NULL ,
    Sat_Scrap_LEDTS      datetime  NULL ,
    Sat_Scrap_RSRC       nvarchar(18)  NULL ,
    Hub_ScrapID_SQN      numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_Scrap PRIMARY KEY  CLUSTERED (Hub_ScrapID_SQN ASC,Sat_Scrap_LDTS ASC),
     FOREIGN KEY (Hub_ScrapID_SQN) REFERENCES Hub_ScrapID(Hub_ScrapID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_ScrapReason_Name ON Sat_Scrap
(
    Name                  ASC
)
go


CREATE TABLE Sat_Prod
(
    Name                 nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    MakeFlag             bit  NOT NULL ,
    FinishedGoodsFlag    bit  NOT NULL ,
    Color                nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL ,
    SafetyStockLevel     smallint  NOT NULL ,
    ReorderPoint         smallint  NOT NULL ,
    StandardCost         money  NOT NULL ,
    ListPrice            money  NOT NULL ,
    Size                 nvarchar(5) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL ,
    Weight               decimal(8,2)  NULL ,
    DaysToManufacture    int  NOT NULL ,
    ProductLine          nchar(2) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL ,
    Class                nchar(2) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL ,
    Style                nchar(2) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL ,
    SellStartDate        datetime  NOT NULL ,
    SellEndDate          datetime  NULL ,
    DiscontinuedDate     datetime  NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_Prod_LDTS        datetime  NOT NULL ,
    Sat_Prod_LEDTS       datetime  NULL ,
    Sat_Prod_RSRC        nvarchar(18)  NULL ,
    Hub_ProdNum_SQN      numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_Prod PRIMARY KEY  CLUSTERED (Hub_ProdNum_SQN ASC,Sat_Prod_LDTS ASC),
     FOREIGN KEY (Hub_ProdNum_SQN) REFERENCES Hub_ProdNum(Hub_ProdNum_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Product_Name ON Sat_Prod
(
    Name                  ASC
)
go


CREATE TABLE Lnk_SOrdNum_AddID
(
    Lnk_SOrdNum_AddID_LDTS datetime  NOT NULL ,
    Lnk_SOrdNum_AddID_RSRC nvarchar(18)  NULL ,
    Lnk_SOrdNum_AddID_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_SOrdNum_SQN      numeric(12)  NULL ,
    Hub_AddID_BillTo_SQN numeric(12)  NULL ,
    Hub_AddID_ShipTo_SQN numeric(12)  NULL ,
    CONSTRAINT XPKLnk_SOrdNum_AddID PRIMARY KEY  CLUSTERED (Lnk_SOrdNum_AddID_SQN ASC),
     FOREIGN KEY (Hub_SOrdNum_SQN) REFERENCES Hub_SOrdNum(Hub_SOrdNum_SQN),
 FOREIGN KEY (Hub_AddID_BillTo_SQN) REFERENCES Hub_AddID(Hub_AddID_SQN),
 FOREIGN KEY (Hub_AddID_ShipTo_SQN) REFERENCES Hub_AddID(Hub_AddID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Lnk_SOrdNum_Add ON Lnk_SOrdNum_AddID
(
    Hub_SOrdNum_SQN       ASC,
    Hub_AddID_BillTo_SQN  ASC,
    Hub_AddID_ShipTo_SQN  ASC
)
go


CREATE TABLE Lnk_ProdNum_WOID
(
    Lnk_ProdNum_WOID_LDTS datetime  NOT NULL ,
    Lnk_ProdNum_WOID_RSRC nvarchar(18)  NULL ,
    Lnk_ProdNum_WOID_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_ProdNum_SQN      numeric(12)  NULL ,
    Hub_WOID_SQN         numeric(12)  NULL ,
    CONSTRAINT PK_Lnk_ProdNum_WOID PRIMARY KEY  CLUSTERED (Lnk_ProdNum_WOID_SQN ASC),
     FOREIGN KEY (Hub_ProdNum_SQN) REFERENCES Hub_ProdNum(Hub_ProdNum_SQN),
 FOREIGN KEY (Hub_WOID_SQN) REFERENCES Hub_Wrk_Ord(Hub_WOID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_WorkOrder ON Lnk_ProdNum_WOID
(
    Hub_ProdNum_SQN       ASC,
    Hub_WOID_SQN          ASC
)
go


CREATE TABLE Lnk_DocNode_EmpID
(
    Lnk_DocNode_EmpID_LDTS datetime  NOT NULL ,
    Lnk_DocNode_EmpID_RSRC nvarchar(18)  NULL ,
    Lnk_DocNode_EmpID_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_EmpID_SQN        numeric(12)  NOT NULL ,
    Hub_DocNode_SQN      numeric(12)  NULL ,
    CONSTRAINT XPKLnk_DocNode_Emp PRIMARY KEY  CLUSTERED (Lnk_DocNode_EmpID_SQN ASC),
     FOREIGN KEY (Hub_EmpID_SQN) REFERENCES Hub_EmpID(Hub_EmpID_SQN),
 FOREIGN KEY (Hub_DocNode_SQN) REFERENCES Hub_DocNode(Hub_DocNode_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Lnk_DocNode_Emp ON Lnk_DocNode_EmpID
(
    Hub_EmpID_SQN         ASC,
    Hub_DocNode_SQN       ASC
)
go


CREATE TABLE Lnk_ProdNum_LocID
(
    Lnk_ProdNum_LocID_LDTS datetime  NOT NULL ,
    Lnk_ProdINum_LocID_RSRC nvarchar(18)  NULL ,
    Lnk_ProdNum_LocID_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_ProdNum_SQN      numeric(12)  NULL ,
    Hub_LocID_SQN        numeric(12)  NULL ,
    CONSTRAINT PK_ProductInventory_ProductID_LocationID PRIMARY KEY  CLUSTERED (Lnk_ProdNum_LocID_SQN ASC),
     FOREIGN KEY (Hub_ProdNum_SQN) REFERENCES Hub_ProdNum(Hub_ProdNum_SQN),
 FOREIGN KEY (Hub_LocID_SQN) REFERENCES Hub_LocID(Hub_LocID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_ProductInventory ON Lnk_ProdNum_LocID
(
    Hub_ProdNum_SQN       ASC,
    Hub_LocID_SQN         ASC
)
go


CREATE TABLE Sat_Prod_Loc
(
    Shelf                nvarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    Bin                  tinyint  NOT NULL ,
    Quantity             smallint  NOT NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_Prod_Loc_LDTS    datetime  NOT NULL ,
    Sat_Prod_Loc_LEDTS   datetime  NULL ,
    Sat_Prod_Loc_RSRC    nvarchar(18)  NULL ,
    Lnk_ProdNum_LocID_SQN numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_Prod_Loc PRIMARY KEY  CLUSTERED (Lnk_ProdNum_LocID_SQN ASC,Sat_Prod_Loc_LDTS ASC),
     FOREIGN KEY (Lnk_ProdNum_LocID_SQN) REFERENCES Lnk_ProdNum_LocID(Lnk_ProdNum_LocID_SQN)
)
go


CREATE TABLE Sat_Pers
(
    PersonType           nchar(2) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    NameStyle            bit  NOT NULL ,
    Title                nvarchar(8) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL ,
    FirstName            nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    MiddleName           nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL ,
    LastName             nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    Suffix               nvarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL ,
    EmailPromotion       int  NOT NULL ,
    AdditionalContactInfo xml  NULL ,
    Demographics         xml  NULL ,
    rowguid              uniqueidentifier  NOT NULL  ROWGUIDCOL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_Pers_LDTS        datetime  NOT NULL ,
    Sat_Pers_LEDTS       datetime  NULL ,
    Sat_Pers_RSRC        nvarchar(18)  NULL ,
    Hub_PersID_SQN       numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_Pers PRIMARY KEY  CLUSTERED (Hub_PersID_SQN ASC,Sat_Pers_LDTS ASC),
     FOREIGN KEY (Hub_PersID_SQN) REFERENCES Hub_PersID(Hub_PersID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Person_rowguid ON Sat_Pers
(
    rowguid               ASC
)
go


CREATE NONCLUSTERED INDEX IX_Person_LastName_FirstName_MiddleName ON Sat_Pers
(
    LastName              ASC,
    FirstName             ASC,
    MiddleName            ASC
)
go


CREATE TABLE Sat_Emp
(
    NationalIDNumber     nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    LoginID              nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    OrganizationNode     char(18)  NOT NULL ,
    OrganizationLevel    smallint  NULL ,
    JobTitle             nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    BirthDate            date  NOT NULL ,
    MaritalStatus        nchar(1) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    Gender               nchar(1) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    HireDate             date  NOT NULL ,
    SalariedFlag         bit  NOT NULL ,
    VacationHours        smallint  NOT NULL ,
    SickLeaveHours       smallint  NOT NULL ,
    CurrentFlag          bit  NOT NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_Emp_LDTS         datetime  NOT NULL ,
    Sat_Emp_LEDTS        datetime  NULL ,
    Sat_Emp_RSRC         nvarchar(18)  NULL ,
    Hub_EmpID_SQN        numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_Emp PRIMARY KEY  CLUSTERED (Hub_EmpID_SQN ASC,Sat_Emp_LDTS ASC),
     FOREIGN KEY (Hub_EmpID_SQN) REFERENCES Hub_EmpID(Hub_EmpID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Employee_OrganizationNode ON Sat_Emp
(
    OrganizationNode      ASC
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Employee_OrganizationLevel_OrganizationNode ON Sat_Emp
(
    OrganizationLevel     ASC,
    OrganizationNode      ASC
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Employee_LoginID ON Sat_Emp
(
    LoginID               ASC
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Employee_NationalIDNumber ON Sat_Emp
(
    NationalIDNumber      ASC
)
go


CREATE TABLE Hub_ProdDescID
(
    ProductDescriptionID int  NOT NULL ,
    Hub_ProdDescID_LDTS  datetime  NOT NULL ,
    Hub_ProdDescID_SQN   numeric(12) IDENTITY (1000,1) ,
    Hub_ProdDescID_RSRC  nvarchar(18)  NULL ,
    CONSTRAINT PK_ProductDescription_ProductDescriptionID PRIMARY KEY  CLUSTERED (Hub_ProdDescID_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_ProductDescriptionID ON Hub_ProdDescID
(
    ProductDescriptionID  ASC
)
go


CREATE TABLE Sat_ProdDesc
(
    Description          nvarchar(400) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_ProdDesc_LDTS    datetime  NOT NULL ,
    Sat_ProdDesc_LEDTS   datetime  NULL ,
    Sat_ProdDesc_RSRC    nvarchar(18)  NULL ,
    Hub_ProdDescID_SQN   numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_ProdDesc PRIMARY KEY  CLUSTERED (Hub_ProdDescID_SQN ASC,Sat_ProdDesc_LDTS ASC),
     FOREIGN KEY (Hub_ProdDescID_SQN) REFERENCES Hub_ProdDescID(Hub_ProdDescID_SQN)
)
go


CREATE TABLE Hub_CultID
(
    CultureID            nchar(6) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    Hub_CultID_LDTS      datetime  NOT NULL ,
    Hub_CultID_RSRC      nvarchar(18)  NULL ,
    Hub_CultID_SQN       numeric(12) IDENTITY (1000,1) ,
    CONSTRAINT PK_Culture_CultureID PRIMARY KEY  CLUSTERED (Hub_CultID_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_CultureID ON Hub_CultID
(
    CultureID             ASC
)
go


CREATE TABLE Sat_Cult
(
    Name                 nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_Cult_LDTS        datetime  NOT NULL ,
    Sat_Cult_LEDTS       datetime  NULL ,
    Sat_Cult_RSRC        nvarchar(18)  NULL ,
    Hub_CultID_SQN       numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_Cult PRIMARY KEY  CLUSTERED (Hub_CultID_SQN ASC,Sat_Cult_LDTS ASC),
     FOREIGN KEY (Hub_CultID_SQN) REFERENCES Hub_CultID(Hub_CultID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Culture_Name ON Sat_Cult
(
    Name                  ASC
)
go


CREATE TABLE Hub_ModID
(
    ProductModelID       int  NOT NULL ,
    Hub_ModID_SQN        numeric(12) IDENTITY (1000,1) ,
    Hub_ModID_LDTS       datetime  NOT NULL ,
    Hub_ModID_RSRC       nvarchar(18)  NULL ,
    CONSTRAINT PK_ProductModel_ProductModelID PRIMARY KEY  CLUSTERED (Hub_ModID_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_ProductModelID ON Hub_ModID
(
    ProductModelID        ASC
)
go


CREATE TABLE Lnk_ModID_ProdDescID_CultID
(
    Lnk_ModID_ProdDescID_CultID_LDTS datetime  NOT NULL ,
    Lnk_ModID_ProdDescID_CultID_SQN numeric(12) IDENTITY (1000,1) ,
    Lnk_ModID_ProdDescID_CultID_RSRC nvarchar(18)  NULL ,
    Hub_CultID_SQN       numeric(12)  NULL ,
    Hub_ProdDescID_SQN   numeric(12)  NULL ,
    Hub_ModID_SQN        numeric(12)  NOT NULL ,
    CONSTRAINT PK_ProductModelProductDescriptionCulture_ProductModelID_ProductD PRIMARY KEY  CLUSTERED (Lnk_ModID_ProdDescID_CultID_SQN ASC),
     FOREIGN KEY (Hub_CultID_SQN) REFERENCES Hub_CultID(Hub_CultID_SQN),
 FOREIGN KEY (Hub_ProdDescID_SQN) REFERENCES Hub_ProdDescID(Hub_ProdDescID_SQN),
 FOREIGN KEY (Hub_ModID_SQN) REFERENCES Hub_ModID(Hub_ModID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_ProductModelProductDescriptionCulture ON Lnk_ModID_ProdDescID_CultID
(
    Hub_CultID_SQN        ASC,
    Hub_ProdDescID_SQN    ASC,
    Hub_ModID_SQN         ASC
)
go


CREATE TABLE Sat_ProdMod_ProdDesc_Cult
(
    ModifiedDate         datetime  NOT NULL ,
    Sat_Mod_ProdDesc_Cult_LDTS datetime  NOT NULL ,
    Sat_Mod_ProdDesc_Cult__LEDTS datetime  NULL ,
    Sat_Mod_ProdDesc_Cult__RSRC nvarchar(18)  NULL ,
    Lnk_ModID_ProdDescID_CultID_SQN numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_ProdMod_ProdDesc_Cult PRIMARY KEY  CLUSTERED (Lnk_ModID_ProdDescID_CultID_SQN ASC,Sat_Mod_ProdDesc_Cult_LDTS ASC),
     FOREIGN KEY (Lnk_ModID_ProdDescID_CultID_SQN) REFERENCES Lnk_ModID_ProdDescID_CultID(Lnk_ModID_ProdDescID_CultID_SQN)
)
go


CREATE TABLE Hub_IllID
(
    IllustrationID       int  NOT NULL ,
    Hub_IllID_SQN        numeric(12) IDENTITY (1000,1) ,
    Hub_IllID_LDTS       datetime  NOT NULL ,
    Hub_IllID_RSRC       nvarchar(18)  NULL ,
    CONSTRAINT PK_Illustration_IllustrationID PRIMARY KEY  CLUSTERED (Hub_IllID_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_IllustrationID ON Hub_IllID
(
    IllustrationID        ASC
)
go


CREATE TABLE Lnk_ModID_IllID
(
    Lnk_ModID_IllID_LDTS datetime  NOT NULL ,
    Lnk_ModID_IllID_SQN  numeric(12) IDENTITY (1000,1) ,
    Lnk_ModID_IllID_RSRC nvarchar(18)  NULL ,
    Hub_IllID_SQN        numeric(12)  NULL ,
    Hub_ModID_SQN        numeric(12)  NULL ,
    CONSTRAINT PK_ProductModelIllustration_ProductModelID_IllustrationID PRIMARY KEY  CLUSTERED (Lnk_ModID_IllID_SQN ASC),
     FOREIGN KEY (Hub_IllID_SQN) REFERENCES Hub_IllID(Hub_IllID_SQN),
 FOREIGN KEY (Hub_ModID_SQN) REFERENCES Hub_ModID(Hub_ModID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_ProductModelIllustration ON Lnk_ModID_IllID
(
    Hub_IllID_SQN         ASC,
    Hub_ModID_SQN         ASC
)
go


CREATE TABLE Sat_ProdMod_Ill
(
    ModifiedDate         datetime  NOT NULL ,
    Sat_ProdMod_Ill_LDTS datetime  NOT NULL ,
    Lnk_ModID_IllID_SQN  numeric(12)  NOT NULL ,
    Sat_ProdMod_Ill_RSRC nvarchar(18)  NULL ,
    Sat_ProdMod_Ill_LEDTS datetime  NULL ,
    CONSTRAINT PK_Sat_ProdMod_Ill PRIMARY KEY  CLUSTERED (Lnk_ModID_IllID_SQN ASC,Sat_ProdMod_Ill_LDTS ASC),
     FOREIGN KEY (Lnk_ModID_IllID_SQN) REFERENCES Lnk_ModID_IllID(Lnk_ModID_IllID_SQN)
)
go


CREATE TABLE Sat_Illustraion
(
    Diagram              xml  NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_Ill_LDTS         datetime  NOT NULL ,
    Sat_Ill_RSRC         nvarchar(18)  NULL ,
    Sat_Ill_LEDTS        datetime  NULL ,
    Hub_IllID_SQN        numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_Illustraion PRIMARY KEY  CLUSTERED (Hub_IllID_SQN ASC,Sat_Ill_LDTS ASC),
     FOREIGN KEY (Hub_IllID_SQN) REFERENCES Hub_IllID(Hub_IllID_SQN)
)
go


CREATE TABLE Hub_POID
(
    PurchaseOrderID      int  NOT NULL ,
    Hub_POID_LDTS        datetime  NOT NULL ,
    Hub_POID_RSRC        nvarchar(18)  NULL ,
    Hub_POID_SQN         numeric(12) IDENTITY (1000,1) ,
    CONSTRAINT PK_PurchaseOrderHeader_PurchaseOrderID PRIMARY KEY  CLUSTERED (Hub_POID_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_PurchaseOrderHeaderID ON Hub_POID
(
    PurchaseOrderID       ASC
)
go


CREATE TABLE Sat_POHead
(
    RevisionNumber       tinyint  NOT NULL ,
    Status               tinyint  NOT NULL ,
    OrderDate            datetime  NOT NULL ,
    ShipDate             datetime  NULL ,
    SubTotal             money  NOT NULL ,
    TaxAmt               money  NOT NULL ,
    Freight              money  NOT NULL ,
    TotalDue             money  NOT NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_POHead_LDTS      datetime  NOT NULL ,
    Sat_POHead_LEDTS     datetime  NULL ,
    Sat_POHead_RSRC      nvarchar(18)  NULL ,
    Hub_POID_SQN         numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_POHead PRIMARY KEY  CLUSTERED (Hub_POID_SQN ASC,Sat_POHead_LDTS ASC),
     FOREIGN KEY (Hub_POID_SQN) REFERENCES Hub_POID(Hub_POID_SQN)
)
go


CREATE TABLE Lnk_EmpID_JobCandID
(
    Lnk_EmpID_JobCandID_LDTS datetime  NOT NULL ,
    Lnk_EmpID_JobCandID_RSRC nvarchar(18)  NULL ,
    Lnk_EmpID_JobCandID_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_EmpID_SQN        numeric(12)  NULL ,
    Hub_JobCandID_SQN    numeric(12)  NULL ,
    CONSTRAINT PK_Lnk_EmpID_JobCandID PRIMARY KEY  CLUSTERED (Lnk_EmpID_JobCandID_SQN ASC),
     FOREIGN KEY (Hub_EmpID_SQN) REFERENCES Hub_EmpID(Hub_EmpID_SQN),
 FOREIGN KEY (Hub_JobCandID_SQN) REFERENCES Hub_JobCandID(Hub_JobCandID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_JobCandidate ON Lnk_EmpID_JobCandID
(
    Hub_EmpID_SQN         ASC,
    Hub_JobCandID_SQN     ASC
)
go


CREATE TABLE Lnk_ProdNum_ModID
(
    Lnk_ProdNum_ModID_SQN numeric(12) IDENTITY (1000,1) ,
    Lnk_ProdNum_ModID_LDTS datetime  NOT NULL ,
    Lnk_ProdNum_ModID_RSRC nvarchar(18)  NULL ,
    Hub_ProdNum_SQN      numeric(12)  NULL ,
    Hub_ModID_SQN        numeric(12)  NULL ,
    CONSTRAINT PK_Lnk_ProdNum_ModID PRIMARY KEY  CLUSTERED (Lnk_ProdNum_ModID_SQN ASC),
     FOREIGN KEY (Hub_ProdNum_SQN) REFERENCES Hub_ProdNum(Hub_ProdNum_SQN),
 FOREIGN KEY (Hub_ModID_SQN) REFERENCES Hub_ModID(Hub_ModID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_ProductModel ON Lnk_ProdNum_ModID
(
    Hub_ProdNum_SQN       ASC,
    Hub_ModID_SQN         ASC
)
go


CREATE TABLE Sat_Mod
(
    Name                 nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    CatalogDescription   xml  NULL ,
    Instructions         xml  NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Hub_ModID_SQN        numeric(12)  NOT NULL ,
    Sat_Mod_LDTS         datetime  NOT NULL ,
    Sat_Mod_RSRC         nvarchar(18)  NULL ,
    Sat_Mod_LEDTS        datetime  NULL ,
    CONSTRAINT PK_Sat_Mod PRIMARY KEY  CLUSTERED (Hub_ModID_SQN ASC,Sat_Mod_LDTS ASC),
     FOREIGN KEY (Hub_ModID_SQN) REFERENCES Hub_ModID(Hub_ModID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_ProductModel_Name ON Sat_Mod
(
    Name                  ASC
)
go


CREATE TABLE Sat_SRsn
(
    Name                 nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    ReasonType           nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_SRsn_LDTS        datetime  NOT NULL ,
    Sat_SRsn_LEDTS       datetime  NULL ,
    Sat_SRsn_RSRC        nvarchar(18)  NULL ,
    Hub_SRsnID_SQN       numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_SRsn PRIMARY KEY  CLUSTERED (Hub_SRsnID_SQN ASC,Sat_SRsn_LDTS ASC),
     FOREIGN KEY (Hub_SRsnID_SQN) REFERENCES Hub_SRsnID(Hub_SRsnID_SQN)
)
go


CREATE TABLE Lnk_PersID_CCID
(
    Lnk_PersID_CCID_LDTS datetime  NOT NULL ,
    Lnk_PersID_CCID_RSRC nvarchar(18)  NULL ,
    Lnk_PersID_CCID_SQN  numeric(12) IDENTITY (1000,1) ,
    Hub_CCID_SQN         numeric(12)  NULL ,
    Hub_PersID_SQN       numeric(12)  NULL ,
    CONSTRAINT PK_PersonCreditCard_BusinessEntityID_CreditCardID PRIMARY KEY  CLUSTERED (Lnk_PersID_CCID_SQN ASC),
     FOREIGN KEY (Hub_CCID_SQN) REFERENCES Hub_CCID(Hub_CCID_SQN),
 FOREIGN KEY (Hub_PersID_SQN) REFERENCES Hub_PersID(Hub_PersID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_PersonCreditCard ON Lnk_PersID_CCID
(
    Hub_PersID_SQN        ASC,
    Hub_CCID_SQN          ASC
)
go


CREATE TABLE Sat_PersID_CCID
(
    ModifiedDate         datetime  NOT NULL ,
    Sat_PersID_CCID_LDTS datetime  NOT NULL ,
    Sat_PersID_CCID_LEDTS datetime  NULL ,
    Sat_PersID_CCID_RSRC nvarchar(18)  NULL ,
    Lnk_PersID_CCID_SQN  numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_PersID_CCID PRIMARY KEY  CLUSTERED (Lnk_PersID_CCID_SQN ASC,Sat_PersID_CCID_LDTS ASC),
     FOREIGN KEY (Lnk_PersID_CCID_SQN) REFERENCES Lnk_PersID_CCID(Lnk_PersID_CCID_SQN)
)
go


CREATE TABLE Sat_SOrd
(
    RevisionNumber       tinyint  NOT NULL ,
    OrderDate            datetime  NOT NULL ,
    DueDate              datetime  NOT NULL ,
    ShipDate             datetime  NULL ,
    Status               tinyint  NOT NULL ,
    OnlineOrderFlag      bit  NOT NULL ,
    PurchaseOrderNumber  nvarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL ,
    AccountNumber        nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL ,
    SubTotal             money  NOT NULL ,
    TaxAmt               money  NOT NULL ,
    Freight              money  NOT NULL ,
    TotalDue             money  NOT NULL ,
    Comment              nvarchar(128) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_SOrd_LDTS        datetime  NOT NULL ,
    Sat_SOrd_LEDTS       datetime  NULL ,
    Sat_SOrd_RSRC        nvarchar(18)  NULL ,
    Hub_SOrdNum_SQN      numeric(12)  NOT NULL ,
    CreditCardApprovalCode varchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL ,
    CONSTRAINT PK_Sat_SOrd PRIMARY KEY  CLUSTERED (Hub_SOrdNum_SQN ASC,Sat_SOrd_LDTS ASC),
     FOREIGN KEY (Hub_SOrdNum_SQN) REFERENCES Hub_SOrdNum(Hub_SOrdNum_SQN)
)
go


CREATE TABLE Sat_Doc
(
    DocumentLevel        smallint  NULL ,
    Title                nvarchar(50)  NOT NULL ,
    FolderFlag           bit  NOT NULL ,
    FileName             nvarchar(400) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    FileExtension        nvarchar(8) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    Revision             nchar(5) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    ChangeNumber         int  NOT NULL ,
    Status               tinyint  NOT NULL ,
    DocumentSummary      nvarchar(max) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL ,
    Document             varbinary(max)  NULL ,
    ModifiedDate         datetime  NOT NULL ,
    PersonID             char(18)  NULL ,
    Sat_Doc_LDTS         datetime  NOT NULL ,
    Sat_Doc_LEDTS        datetime  NULL ,
    Sat_Doc_RSRC         nvarchar(18)  NULL ,
    Hub_DocNode_SQN      numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_Doc PRIMARY KEY  CLUSTERED (Hub_DocNode_SQN ASC,Sat_Doc_LDTS ASC),
     FOREIGN KEY (Hub_DocNode_SQN) REFERENCES Hub_DocNode(Hub_DocNode_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Document_DocumentLevel_DocumentNode ON Sat_Doc
(
    DocumentLevel         ASC
)
go


CREATE NONCLUSTERED INDEX IX_Document_FileName_Revision ON Sat_Doc
(
    FileName              ASC,
    Revision              ASC
)
go


CREATE TABLE Hub_VendNum
(
    AccountNumber        nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    Hub_VendNum_LDTS     datetime  NOT NULL ,
    Hub_VendNum_RSRC     nvarchar(18)  NULL ,
    Hub_VendNum_SQN      numeric(12) IDENTITY (1000,1) ,
    CONSTRAINT PK_Vendor_BusinessEntityID PRIMARY KEY  CLUSTERED (Hub_VendNum_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_AccountNumber ON Hub_VendNum
(
    AccountNumber         ASC
)
go


CREATE TABLE Lnk_BusEntID_VendNum
(
    Lnk_BusEntID_VendNum_LDTS datetime  NOT NULL ,
    Lnk_BusEntID_VendNum_RSRC nvarchar(18)  NULL ,
    Lnk_BusEntID_VendNum_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_BusEntID_SQN     numeric(12)  NULL ,
    Hub_VendNum_SQN      numeric(12)  NULL ,
    CONSTRAINT XPKLnk_BusEntID_AcctNum PRIMARY KEY  CLUSTERED (Lnk_BusEntID_VendNum_SQN ASC),
     FOREIGN KEY (Hub_BusEntID_SQN) REFERENCES Hub_BusEntID(Hub_BusEntID_SQN),
 FOREIGN KEY (Hub_VendNum_SQN) REFERENCES Hub_VendNum(Hub_VendNum_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Lnk_BusEntID_AcctNum ON Lnk_BusEntID_VendNum
(
    Hub_BusEntID_SQN      ASC,
    Hub_VendNum_SQN       ASC
)
go


CREATE TABLE Hub_EmailAddID
(
    EmailAddressID       int  NOT NULL ,
    Hub_EmailAddID_LDTS  datetime  NOT NULL ,
    Hub_EmailAddID_RSRC  nvarchar(18)  NULL ,
    Hub_EmailAddID_SQN   numeric(12) IDENTITY (1000,1) ,
    CONSTRAINT PK_EmailAddress_BusinessEntityID_EmailAddressID PRIMARY KEY  CLUSTERED (Hub_EmailAddID_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_EmailAddressID ON Hub_EmailAddID
(
    EmailAddressID        ASC
)
go


CREATE TABLE Lnk_PersID_EmailAddID
(
    Lnk_PersID_EmailAddID_LDTS datetime  NOT NULL ,
    Lnk_PersID_EmailAddID_RSRC nvarchar(18)  NULL ,
    Lnk_PersID_EmailAddID_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_PersID_SQN       numeric(12)  NULL ,
    Hub_EmailAddID_SQN   numeric(12)  NULL ,
    CONSTRAINT PK_Lnk_PersID_EmailAddID PRIMARY KEY  CLUSTERED (Lnk_PersID_EmailAddID_SQN ASC),
     FOREIGN KEY (Hub_PersID_SQN) REFERENCES Hub_PersID(Hub_PersID_SQN),
 FOREIGN KEY (Hub_EmailAddID_SQN) REFERENCES Hub_EmailAddID(Hub_EmailAddID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_EmailAddress ON Lnk_PersID_EmailAddID
(
    Hub_PersID_SQN        ASC,
    Hub_EmailAddID_SQN    ASC
)
go


CREATE TABLE Hub_ShiftID
(
    ShiftID              tinyint  NOT NULL ,
    Hub_ShiftID_LDTS     datetime  NOT NULL ,
    Hub_ShiftID_RSRC     nvarchar(18)  NULL ,
    Hub_ShiftID_SQN      numeric(12) IDENTITY (1000,1) ,
    CONSTRAINT PK_Shift_ShiftID PRIMARY KEY  CLUSTERED (Hub_ShiftID_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_ShiftID ON Hub_ShiftID
(
    ShiftID               ASC
)
go


CREATE TABLE Hub_DepID
(
    DepartmentID         smallint  NOT NULL ,
    Hub_DepID_LDTS       datetime  NOT NULL ,
    Hub_DepID_RSRC       nvarchar(18)  NULL ,
    Hub_DepID_SQN        numeric(12) IDENTITY (1000,1) ,
    CONSTRAINT PK_Department_DepartmentID PRIMARY KEY  CLUSTERED (Hub_DepID_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_DepartmentID ON Hub_DepID
(
    DepartmentID          ASC
)
go


CREATE TABLE Lnk_EmpID_DepID_ShiftID
(
    Lnk_EmpID_DepID_ShiftID_LDTS datetime  NOT NULL ,
    Lnk_EmpID_DepID_ShiftID_RSRC nvarchar(18)  NULL ,
    Lnk_EmpID_DepID_ShiftID_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_EmpID_SQN        numeric(12)  NULL ,
    Hub_ShiftID_SQN      numeric(12)  NULL ,
    Hub_DepID_SQN        numeric(12)  NULL ,
    CONSTRAINT PK_EmployeeDepartmentHistory PRIMARY KEY  CLUSTERED (Lnk_EmpID_DepID_ShiftID_SQN ASC),
     FOREIGN KEY (Hub_EmpID_SQN) REFERENCES Hub_EmpID(Hub_EmpID_SQN),
 FOREIGN KEY (Hub_ShiftID_SQN) REFERENCES Hub_ShiftID(Hub_ShiftID_SQN),
 FOREIGN KEY (Hub_DepID_SQN) REFERENCES Hub_DepID(Hub_DepID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_EmployeeDepartmentHistory ON Lnk_EmpID_DepID_ShiftID
(
    Hub_EmpID_SQN         ASC,
    Hub_ShiftID_SQN       ASC,
    Hub_DepID_SQN         ASC
)
go


CREATE TABLE Sat_EmpID_DepID_ShiftID
(
    StartDate            date  NOT NULL ,
    EndDate              date  NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_EmpID_DepID_ShiftID_LDTS datetime  NOT NULL ,
    Sat_EmpID_DepID_ShiftID_LEDTS datetime  NULL ,
    Sat_EmpID_DepID_ShiftID_RSRC nvarchar(18)  NULL ,
    Lnk_EmpID_DepID_ShiftID_SQN numeric(12)  NOT NULL ,
    CONSTRAINT PK_EmployeeDepartmentHistory_BusinessEntityID_StartDate_Departme PRIMARY KEY  CLUSTERED (Lnk_EmpID_DepID_ShiftID_SQN ASC,Sat_EmpID_DepID_ShiftID_LDTS ASC),
     FOREIGN KEY (Lnk_EmpID_DepID_ShiftID_SQN) REFERENCES Lnk_EmpID_DepID_ShiftID(Lnk_EmpID_DepID_ShiftID_SQN)
)
go


CREATE TABLE Sat_Dep
(
    Name                 nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    GroupName            nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_Dep_LDTS         datetime  NOT NULL ,
    Sat_Dep_LEDTS        datetime  NULL ,
    Sat_Dep_RSRC         nvarchar(18)  NULL ,
    Hub_DepID_SQN        numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_Dep PRIMARY KEY  CLUSTERED (Hub_DepID_SQN ASC,Sat_Dep_LDTS ASC),
     FOREIGN KEY (Hub_DepID_SQN) REFERENCES Hub_DepID(Hub_DepID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Department_Name ON Sat_Dep
(
    Name                  ASC
)
go


CREATE TABLE Hub_CntryRgnCd
(
    CountryRegionCode    nvarchar(3) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    Hub_CntryRgnCd_LDTS  datetime  NOT NULL ,
    Hub_CntryRgnCd_RSRC  nvarchar(18)  NULL ,
    Hub_CntryRgnCd_SQN   numeric(12) IDENTITY (1000,1) ,
    CONSTRAINT PK_CountryRegion_CountryRegionCode PRIMARY KEY  CLUSTERED (Hub_CntryRgnCd_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_CountryRegionCode ON Hub_CntryRgnCd
(
    CountryRegionCode     ASC
)
go


CREATE TABLE Hub_CrncyCd
(
    CurrencyCode         nchar(3) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    Hub_CrncyCd_LDTS     datetime  NOT NULL ,
    Hub_CrncyCd_RSRC     nvarchar(18)  NULL ,
    Hub_CrncyCd_SQN      numeric(12) IDENTITY (1000,1) ,
    CONSTRAINT PK_Currency_CurrencyCode PRIMARY KEY  CLUSTERED (Hub_CrncyCd_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_CurrencyCode ON Hub_CrncyCd
(
    CurrencyCode          ASC
)
go


CREATE TABLE Lnk_CntryRgnID_CrncyCd
(
    Lnk_CntryRgnID_CrncyCd_LDTS datetime  NOT NULL ,
    Lnk_CntryRgnID_CrncyCd_RSRC nvarchar(18)  NULL ,
    Lnk_CntryRgnID_CrncyCd_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_CntryRgnCd_SQN   numeric(12)  NULL ,
    Hub_CrncyCd_SQN      numeric(12)  NULL ,
    CONSTRAINT XPKLnk_CntryRgnID_Crncy PRIMARY KEY  CLUSTERED (Lnk_CntryRgnID_CrncyCd_SQN ASC),
     FOREIGN KEY (Hub_CntryRgnCd_SQN) REFERENCES Hub_CntryRgnCd(Hub_CntryRgnCd_SQN),
 FOREIGN KEY (Hub_CrncyCd_SQN) REFERENCES Hub_CrncyCd(Hub_CrncyCd_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Lnk_CntryRgnID_Crncy ON Lnk_CntryRgnID_CrncyCd
(
    Hub_CntryRgnCd_SQN    ASC,
    Hub_CrncyCd_SQN       ASC
)
go


CREATE TABLE Sat_CntryRgn_Crncy
(
    ModifiedDate         datetime  NOT NULL ,
    Sat_CntryRgn_Crncy_LDTS datetime  NOT NULL ,
    Sat_CntryRgn_Crncy_LEDTS datetime  NULL ,
    Sat_CntryRgn_Crncy_RSRC nvarchar(18)  NULL ,
    Lnk_CntryRgnID_CrncyCd_SQN numeric(12)  NOT NULL ,
    CONSTRAINT PK_CountryRegionCurrency_CountryRegionCode_CurrencyCode PRIMARY KEY  CLUSTERED (Lnk_CntryRgnID_CrncyCd_SQN ASC,Sat_CntryRgn_Crncy_LDTS ASC),
     FOREIGN KEY (Lnk_CntryRgnID_CrncyCd_SQN) REFERENCES Lnk_CntryRgnID_CrncyCd(Lnk_CntryRgnID_CrncyCd_SQN)
)
go


CREATE TABLE Sat_Shift
(
    Name                 nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    StartTime            time  NOT NULL ,
    EndTime              time  NOT NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_Shift_LDTS       datetime  NOT NULL ,
    Sat_Shift_LEDTS      datetime  NULL ,
    Sat_Shift_RSRC       nvarchar(18)  NULL ,
    Hub_ShiftID_SQN      numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_Shift PRIMARY KEY  CLUSTERED (Hub_ShiftID_SQN ASC,Sat_Shift_LDTS ASC),
     FOREIGN KEY (Hub_ShiftID_SQN) REFERENCES Hub_ShiftID(Hub_ShiftID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Shift_Name ON Sat_Shift
(
    Name                  ASC
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Shift_StartTime_EndTime ON Sat_Shift
(
    StartTime             ASC,
    EndTime               ASC
)
go


CREATE TABLE Sat_Vend
(
    Name                 nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    CreditRating         tinyint  NOT NULL ,
    PreferredVendorStatus bit  NOT NULL ,
    ActiveFlag           bit  NOT NULL ,
    PurchasingWebServiceURL nvarchar(1024) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_Vend_LDTS        datetime  NOT NULL ,
    Sat_Vend_LEDTS       datetime  NULL ,
    Sat_Vend_RSRC        nvarchar(18)  NULL ,
    Hub_VendNum_SQN      numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_Vend PRIMARY KEY  CLUSTERED (Hub_VendNum_SQN ASC,Sat_Vend_LDTS ASC),
     FOREIGN KEY (Hub_VendNum_SQN) REFERENCES Hub_VendNum(Hub_VendNum_SQN)
)
go


CREATE TABLE Hub_UntMsrCd
(
    UnitMeasureCode      nchar(3) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    Hub_UntMsrCd_LDTS    datetime  NOT NULL ,
    Hub_UntMsrCd_RSRC    nvarchar(18)  NULL ,
    Hub_UntMsrCd_SQN     numeric(12) IDENTITY (1000,1) ,
    CONSTRAINT PK_UnitMeasure_UnitMeasureCode PRIMARY KEY  CLUSTERED (Hub_UntMsrCd_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_UnitMeasureCode ON Hub_UntMsrCd
(
    UnitMeasureCode       ASC
)
go


CREATE TABLE Lnk_ProdNum_VendNum_UntMsrCd
(
    Lnk_ProdNum_VendNum_UntMsrCd_LDTS nvarchar(18)  NULL ,
    Lnk_ProdNum_VendNum_UntMsrCd_RSRC nvarchar(18)  NULL ,
    Lnk_ProdNum_VendNum_UntMsrCd_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_ProdNum_SQN      numeric(12)  NULL ,
    Hub_VendNum_SQN      numeric(12)  NULL ,
    Hub_UntMsrCd_SQN     numeric(12)  NULL ,
    CONSTRAINT PK_ProductVendor_ProductID_BusinessEntityID PRIMARY KEY  CLUSTERED (Lnk_ProdNum_VendNum_UntMsrCd_SQN ASC),
     FOREIGN KEY (Hub_ProdNum_SQN) REFERENCES Hub_ProdNum(Hub_ProdNum_SQN),
 FOREIGN KEY (Hub_VendNum_SQN) REFERENCES Hub_VendNum(Hub_VendNum_SQN),
 FOREIGN KEY (Hub_UntMsrCd_SQN) REFERENCES Hub_UntMsrCd(Hub_UntMsrCd_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_ProductVendor ON Lnk_ProdNum_VendNum_UntMsrCd
(
    Hub_ProdNum_SQN       ASC,
    Hub_VendNum_SQN       ASC,
    Hub_UntMsrCd_SQN      ASC
)
go


CREATE TABLE Sat_ProdNum_VendNum_UntMsrCd
(
    AverageLeadTime      int  NOT NULL ,
    StandardPrice        money  NOT NULL ,
    LastReceiptCost      money  NULL ,
    LastReceiptDate      datetime  NULL ,
    MinOrderQty          int  NOT NULL ,
    MaxOrderQty          int  NOT NULL ,
    OnOrderQty           int  NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_ProdNum_VendNum_UntMsrCd_LDTS datetime  NOT NULL ,
    Sat_ProdNum_VendNum_UntMsrCd_LEDTS datetime  NULL ,
    Sat_ProdNum_VendNum_UntMsrCd_RSRC nvarchar(18)  NULL ,
    Lnk_ProdNum_VendNum_UntMsrCd_SQN numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_ProdNum_VendNum_UntMsrCd PRIMARY KEY  CLUSTERED (Lnk_ProdNum_VendNum_UntMsrCd_SQN ASC,Sat_ProdNum_VendNum_UntMsrCd_LDTS ASC),
     FOREIGN KEY (Lnk_ProdNum_VendNum_UntMsrCd_SQN) REFERENCES Lnk_ProdNum_VendNum_UntMsrCd(Lnk_ProdNum_VendNum_UntMsrCd_SQN)
)
go


CREATE TABLE Lnk_EmpID_POID
(
    Lnk_EmpID_POID_LDTS  datetime  NOT NULL ,
    Lnk_EmpID_POID_RSRC  nvarchar(18)  NULL ,
    Lnk_EmpID_POID_SQN   numeric(12) IDENTITY (1000,1) ,
    Hub_POID_SQN         numeric(12)  NULL ,
    Hub_EmpID_SQN        numeric(12)  NULL ,
    CONSTRAINT XPKLnk_EmpID_POID PRIMARY KEY  CLUSTERED (Lnk_EmpID_POID_SQN ASC),
     FOREIGN KEY (Hub_POID_SQN) REFERENCES Hub_POID(Hub_POID_SQN),
 FOREIGN KEY (Hub_EmpID_SQN) REFERENCES Hub_EmpID(Hub_EmpID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Lnk_EmpID_POID ON Lnk_EmpID_POID
(
    Hub_POID_SQN          ASC,
    Hub_EmpID_SQN         ASC
)
go


CREATE TABLE Hub_ShpMthdID
(
    ShipMethodID         int  NOT NULL ,
    Hub_ShpMthID_LDTS    datetime  NOT NULL ,
    Hub_ShpMthID_RSRC    nvarchar(18)  NULL ,
    Hub_ShpMthID_SQN     numeric(12) IDENTITY (1000,1) ,
    CONSTRAINT PK_ShipMethod_ShipMethodID PRIMARY KEY  CLUSTERED (Hub_ShpMthID_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_ShipMethodID ON Hub_ShpMthdID
(
    ShipMethodID          ASC
)
go


CREATE TABLE Lnk_POID_ShpMthdID
(
    Lnk_POID_ShpMthdID_LDTS datetime  NOT NULL ,
    Lnk_POID_ShpMthdID_RSRC nvarchar(18)  NULL ,
    Lnk_POID_ShpMthdID_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_POID_SQN         numeric(12)  NULL ,
    Hub_ShpMthID_SQN     numeric(12)  NULL ,
    CONSTRAINT XPKLnk_POID_ShPMthdID PRIMARY KEY  CLUSTERED (Lnk_POID_ShpMthdID_SQN ASC),
     FOREIGN KEY (Hub_POID_SQN) REFERENCES Hub_POID(Hub_POID_SQN),
 FOREIGN KEY (Hub_ShpMthID_SQN) REFERENCES Hub_ShpMthdID(Hub_ShpMthID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Lnk_POID_ShPMthdID ON Lnk_POID_ShpMthdID
(
    Hub_POID_SQN          ASC,
    Hub_ShpMthID_SQN      ASC
)
go


CREATE TABLE Lnk_VendNum_POID
(
    Lnk_VendNum_POID_LDTS datetime  NOT NULL ,
    Lnk_VendNum_POID_RSRC nvarchar(18)  NULL ,
    Lnk_VendNum_POID_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_VendNum_SQN      numeric(12)  NULL ,
    Hub_POID_SQN         numeric(12)  NULL ,
    CONSTRAINT XPKLnk_AcctNum_POID PRIMARY KEY  CLUSTERED (Lnk_VendNum_POID_SQN ASC),
     FOREIGN KEY (Hub_VendNum_SQN) REFERENCES Hub_VendNum(Hub_VendNum_SQN),
 FOREIGN KEY (Hub_POID_SQN) REFERENCES Hub_POID(Hub_POID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Lnk_AcctNum_POID ON Lnk_VendNum_POID
(
    Hub_VendNum_SQN       ASC,
    Hub_POID_SQN          ASC
)
go


CREATE TABLE Hub_CustID
(
    CustomerID           int  NOT NULL ,
    Hub_CustID_LDTS      datetime  NOT NULL ,
    Hub_CustID_RSRC      nvarchar(18)  NULL ,
    Hub_CustID_SQN       numeric(12) IDENTITY (1000,1) ,
    CONSTRAINT PK_Customer_CustomerID PRIMARY KEY  CLUSTERED (Hub_CustID_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_CustomerID ON Hub_CustID
(
    CustomerID            ASC
)
go


CREATE TABLE Sat_Cust
(
    PersonID             char(18)  NULL ,
    StoreID              char(18)  NULL ,
    TerritoryID          char(18)  NULL ,
    AccountNumber        varchar(10)  NOT NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_Cust_LDTS        datetime  NOT NULL ,
    Sat_Cust_LEDTS       datetime  NULL ,
    Sat_Cust_RSRC        nvarchar(18)  NULL ,
    Hub_CustID_SQN       numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_Cust PRIMARY KEY  CLUSTERED (Hub_CustID_SQN ASC,Sat_Cust_LDTS ASC),
     FOREIGN KEY (Hub_CustID_SQN) REFERENCES Hub_CustID(Hub_CustID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Customer_AccountNumber ON Sat_Cust
(
    AccountNumber         ASC
)
go


CREATE TABLE Hub_PNTID
(
    PhoneNumberTypeID    int  NOT NULL ,
    Hub_PNTID_LDTS       datetime  NOT NULL ,
    Hub_PNTID_RSRC       nvarchar(18)  NULL ,
    Hub_PNTID_SQN        numeric(12) IDENTITY (1000,1) ,
    CONSTRAINT PK_PhoneNumberType_PhoneNumberTypeID PRIMARY KEY  CLUSTERED (Hub_PNTID_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_PhoneNumberTypeID ON Hub_PNTID
(
    PhoneNumberTypeID     ASC
)
go


CREATE TABLE Sat_PNT
(
    Name                 nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_PNT_LDTS         datetime  NOT NULL ,
    Sat_PNT_LEDTS        datetime  NULL ,
    Sat_PNT_RSRC         nvarchar(18)  NULL ,
    Hub_PNTID_SQN        numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_PNT PRIMARY KEY  CLUSTERED (Hub_PNTID_SQN ASC,Sat_PNT_LDTS ASC),
     FOREIGN KEY (Hub_PNTID_SQN) REFERENCES Hub_PNTID(Hub_PNTID_SQN)
)
go


CREATE TABLE Hub_Phon
(
    PhoneNumber          nvarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    Hub_Phon_LDTS        datetime  NOT NULL ,
    Hub_Phon_RSRC        nvarchar(18)  NULL ,
    Hub_Phon_SQN         numeric(12) IDENTITY (1000,1) ,
    CONSTRAINT PK_PersonPhone_BusinessEntityID_PhoneNumber_PhoneNumberTypeID PRIMARY KEY  CLUSTERED (Hub_Phon_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_PhoneNumber ON Hub_Phon
(
    PhoneNumber           ASC
)
go


CREATE TABLE Sat_Phon
(
    ModifiedDate         datetime  NOT NULL ,
    Sat_Phon_LDTS        datetime  NOT NULL ,
    Sat_Phon_LEDTS       datetime  NULL ,
    Sat_Phon_RSRC        nvarchar(18)  NULL ,
    Hub_Phon_SQN         numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_Phon PRIMARY KEY  CLUSTERED (Hub_Phon_SQN ASC,Sat_Phon_LDTS ASC),
     FOREIGN KEY (Hub_Phon_SQN) REFERENCES Hub_Phon(Hub_Phon_SQN)
)
go


CREATE TABLE Lnk_PersID_Phon_PNTID
(
    Lnk_PersID_Phon_PNTID_LDTS datetime  NOT NULL ,
    Lnk_PersID_Phon_PNTID_RSRC nvarchar(18)  NULL ,
    Lnk_PersID_Phon_PNTID_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_PersID_SQN       numeric(12)  NULL ,
    Hub_Phon_SQN         numeric(12)  NULL ,
    Hub_PNTID_SQN        numeric(12)  NULL ,
    CONSTRAINT XPKLnk_PersID_Phon_PNTID PRIMARY KEY  CLUSTERED (Lnk_PersID_Phon_PNTID_SQN ASC),
     FOREIGN KEY (Hub_PersID_SQN) REFERENCES Hub_PersID(Hub_PersID_SQN),
 FOREIGN KEY (Hub_Phon_SQN) REFERENCES Hub_Phon(Hub_Phon_SQN),
 FOREIGN KEY (Hub_PNTID_SQN) REFERENCES Hub_PNTID(Hub_PNTID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Lnk_PersID_Phon_PNTID ON Lnk_PersID_Phon_PNTID
(
    Hub_PersID_SQN        ASC,
    Hub_Phon_SQN          ASC,
    Hub_PNTID_SQN         ASC
)
go


CREATE TABLE Sat_EmailAdd
(
    EmailAddress         nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_EmailAdd_LDTS    datetime  NOT NULL ,
    Sat_EmailAdd_LEDTS   datetime  NULL ,
    Sat_EmailAdd_RSRC    nvarchar(18)  NULL ,
    Hub_EmailAddID_SQN   numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_EmailAdd PRIMARY KEY  CLUSTERED (Hub_EmailAddID_SQN ASC,Sat_EmailAdd_LDTS ASC),
     FOREIGN KEY (Hub_EmailAddID_SQN) REFERENCES Hub_EmailAddID(Hub_EmailAddID_SQN)
)
go


CREATE NONCLUSTERED INDEX IX_EmailAddress_EmailAddress ON Sat_EmailAdd
(
    EmailAddress          ASC
)
go


CREATE TABLE Lnk_SOrdNum_ShpMthdID
(
    Lnk_SOrdNum_ShpMthdID_LDTS datetime  NOT NULL ,
    Lnk_SOrdNum_ShpMthdID_RSRC nvarchar(18)  NULL ,
    Lnk_SOrdNum_ShpMthdID_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_ShpMthID_SQN     numeric(12)  NULL ,
    Hub_SOrdNum_SQN      numeric(12)  NULL ,
    CONSTRAINT XPKLnk_SOrdNum_ShpMthdID PRIMARY KEY  CLUSTERED (Lnk_SOrdNum_ShpMthdID_SQN ASC),
     FOREIGN KEY (Hub_ShpMthID_SQN) REFERENCES Hub_ShpMthdID(Hub_ShpMthID_SQN),
 FOREIGN KEY (Hub_SOrdNum_SQN) REFERENCES Hub_SOrdNum(Hub_SOrdNum_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Lnk_POID_ShPMthdID ON Lnk_SOrdNum_ShpMthdID
(
    Hub_ShpMthID_SQN      ASC,
    Hub_SOrdNum_SQN       ASC
)
go


CREATE TABLE Sat_Pswrd
(
    PasswordHash         varchar(128) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    PasswordSalt         varchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_Pswrd_LDTS       datetime  NOT NULL ,
    Sat_Pswrd_LEDTS      datetime  NULL ,
    Sat_Pswrd_RSRC       nvarchar(18)  NULL ,
    Hub_PersID_SQN       numeric(12)  NOT NULL ,
    CONSTRAINT PK_Password_BusinessEntityID PRIMARY KEY  CLUSTERED (Hub_PersID_SQN ASC,Sat_Pswrd_LDTS ASC),
     FOREIGN KEY (Hub_PersID_SQN) REFERENCES Hub_PersID(Hub_PersID_SQN)
)
go


CREATE TABLE Lnk_ProdNum_POID
(
    Lnk_ProdNum_POID_LDTS datetime  NOT NULL ,
    Lnk_ProdNum_POID_RSRC nvarchar(18)  NULL ,
    Lnk_ProdNum_POID_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_ProdNum_SQN      numeric(12)  NULL ,
    PurchaseOrderDetailID int  NOT NULL ,
    Hub_POID_SQN         numeric(12)  NULL ,
    CONSTRAINT PK_PurchaseOrderDetail_PurchaseOrderID_PurchaseOrderDetailID PRIMARY KEY  CLUSTERED (Lnk_ProdNum_POID_SQN ASC),
     FOREIGN KEY (Hub_ProdNum_SQN) REFERENCES Hub_ProdNum(Hub_ProdNum_SQN),
 FOREIGN KEY (Hub_POID_SQN) REFERENCES Hub_POID(Hub_POID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_PurchaseOrderDetail ON Lnk_ProdNum_POID
(
    Hub_ProdNum_SQN       ASC,
    PurchaseOrderDetailID  ASC,
    Hub_POID_SQN          ASC
)
go


CREATE TABLE Sat_PODetail
(
    DueDate              datetime  NOT NULL ,
    OrderQty             smallint  NOT NULL ,
    ProductID            char(18)  NOT NULL ,
    UnitPrice            money  NOT NULL ,
    LineTotal            money  NOT NULL ,
    ReceivedQty          decimal(8,2)  NOT NULL ,
    RejectedQty          decimal(8,2)  NOT NULL ,
    StockedQty           decimal(9,2)  NOT NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_PODetail_LDTS    datetime  NOT NULL ,
    Sat_PODetail_LEDTS   datetime  NULL ,
    Sat_PODetail_RSRC    nvarchar(18)  NULL ,
    Lnk_ProdNum_POID_SQN numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_PODetail PRIMARY KEY  CLUSTERED (Lnk_ProdNum_POID_SQN ASC,Sat_PODetail_LDTS ASC),
     FOREIGN KEY (Lnk_ProdNum_POID_SQN) REFERENCES Lnk_ProdNum_POID(Lnk_ProdNum_POID_SQN)
)
go


CREATE TABLE Sat_ShpMthd
(
    Name                 nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    ShipBase             money  NOT NULL ,
    ShipRate             money  NOT NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_ShpMthd_LDTS     datetime  NOT NULL ,
    Sat_ShpMthd_LEDTS    datetime  NULL ,
    Sat_ShpMthd_RSRC     nvarchar(18)  NULL ,
    Hub_ShpMthID_SQN     numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_ShpMthd PRIMARY KEY  CLUSTERED (Hub_ShpMthID_SQN ASC,Sat_ShpMthd_LDTS ASC),
     FOREIGN KEY (Hub_ShpMthID_SQN) REFERENCES Hub_ShpMthdID(Hub_ShpMthID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_ShipMethod_Name ON Sat_ShpMthd
(
    Name                  ASC
)
go


CREATE TABLE Hub_SaleTaxRtID
(
    SalesTaxRateID       int  NOT NULL ,
    Hub_SaleTaxRtID_LDTS datetime  NOT NULL ,
    Hub_SaleTaxRtID_RSRC nvarchar(18)  NULL ,
    Hub_SaleTaxRtID_SQN  numeric(12) IDENTITY (1000,1) ,
    CONSTRAINT PK_SalesTaxRate_SalesTaxRateID PRIMARY KEY  CLUSTERED (Hub_SaleTaxRtID_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_SalesTaxRateID ON Hub_SaleTaxRtID
(
    SalesTaxRateID        ASC
)
go


CREATE TABLE Lnk_StProvID_SaleTaxRtID
(
    Lnk_StProvID_SaleTaxRtID_LDTS datetime  NOT NULL ,
    Lnk_StProvID_SaleTaxRtID_RSRC nvarchar(18)  NULL ,
    Lnk_StProvID_SaleTaxRtID_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_StProvID_SQN     numeric(12)  NULL ,
    Hub_SaleTaxRtID_SQN  numeric(12)  NULL ,
    CONSTRAINT XPKLnk_StProvID_SaleTaxRtID PRIMARY KEY  CLUSTERED (Lnk_StProvID_SaleTaxRtID_SQN ASC),
     FOREIGN KEY (Hub_StProvID_SQN) REFERENCES Hub_StProvID(Hub_StProvID_SQN),
 FOREIGN KEY (Hub_SaleTaxRtID_SQN) REFERENCES Hub_SaleTaxRtID(Hub_SaleTaxRtID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Lnk_StProvID_SaleTaxRtID ON Lnk_StProvID_SaleTaxRtID
(
    Hub_StProvID_SQN      ASC,
    Hub_SaleTaxRtID_SQN   ASC
)
go


CREATE TABLE Hub_Store
(
    BusinessEntityID     char(18)  NOT NULL ,
    Hub_Store_LDTS       datetime  NOT NULL ,
    Hub_Store_RSRC       nvarchar(18)  NULL ,
    Hub_Store_SQN        numeric(12) IDENTITY (1000,1) ,
    CONSTRAINT PK_Store_BusinessEntityID PRIMARY KEY  CLUSTERED (Hub_Store_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_BusinessEntityID ON Hub_Store
(
    BusinessEntityID      ASC
)
go


CREATE TABLE Lnk_BusEntID_Store
(
    Lnk_BusEntID_Store_LDTS datetime  NOT NULL ,
    Lnk_BusEntID_Store_RSRC nvarchar(18)  NULL ,
    Lnk_BusEntID_Store_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_BusEntID_SQN     numeric(12)  NULL ,
    Hub_Store_SQN        numeric(12)  NULL ,
    CONSTRAINT XPKLnk_BEID_Store PRIMARY KEY  CLUSTERED (Lnk_BusEntID_Store_SQN ASC),
     FOREIGN KEY (Hub_BusEntID_SQN) REFERENCES Hub_BusEntID(Hub_BusEntID_SQN),
 FOREIGN KEY (Hub_Store_SQN) REFERENCES Hub_Store(Hub_Store_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Lnk_BEID_Store ON Lnk_BusEntID_Store
(
    Hub_BusEntID_SQN      ASC,
    Hub_Store_SQN         ASC
)
go


CREATE TABLE Hub_SalePers
(
    EmployeeID           char(18)  NOT NULL ,
    Hub_SalePers_LDTS    datetime  NOT NULL ,
    Hub_SalePers_RSRC    nvarchar(18)  NULL ,
    Hub_SalePers_SQN     numeric(12) IDENTITY (1000,1) ,
    CONSTRAINT PK_SalesPerson_BusinessEntityID PRIMARY KEY  CLUSTERED (Hub_SalePers_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_SalesPersonID ON Hub_SalePers
(
    EmployeeID            ASC
)
go


CREATE TABLE Lnk_EmpID_SalePers
(
    Lnk_EmpID_SalePers_LDTS datetime  NOT NULL ,
    Lnk_EmpID_SalePers_RSRC nvarchar(18)  NULL ,
    Lnk_EmpID_SalePers_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_EmpID_SQN        numeric(12)  NULL ,
    Hub_SalePers_SQN     numeric(12)  NULL ,
    CONSTRAINT XPKLnk_EmpID_SalePers PRIMARY KEY  CLUSTERED (Lnk_EmpID_SalePers_SQN ASC),
     FOREIGN KEY (Hub_EmpID_SQN) REFERENCES Hub_EmpID(Hub_EmpID_SQN),
 FOREIGN KEY (Hub_SalePers_SQN) REFERENCES Hub_SalePers(Hub_SalePers_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Lnk_EmpID_SalePers ON Lnk_EmpID_SalePers
(
    Hub_EmpID_SQN         ASC,
    Hub_SalePers_SQN      ASC
)
go


CREATE TABLE Lnk_SalePers_Store
(
    Lnk_SalePers_Store_LDTS datetime  NOT NULL ,
    Lnk_SalePers_Store_RSRC nvarchar(18)  NULL ,
    Lnk_SalePers_Store_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_SalePers_SQN     numeric(12)  NULL ,
    Hub_Store_SQN        numeric(12)  NULL ,
    CONSTRAINT XPKLnk_SalePers_Store PRIMARY KEY  CLUSTERED (Lnk_SalePers_Store_SQN ASC),
     FOREIGN KEY (Hub_SalePers_SQN) REFERENCES Hub_SalePers(Hub_SalePers_SQN),
 FOREIGN KEY (Hub_Store_SQN) REFERENCES Hub_Store(Hub_Store_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Lnk_SalePers_Store ON Lnk_SalePers_Store
(
    Hub_SalePers_SQN      ASC,
    Hub_Store_SQN         ASC
)
go


CREATE TABLE Hub_BOMID
(
    BillOfMaterialsID    int  NOT NULL ,
    Hub_BOMID_LDTS       datetime  NOT NULL ,
    Hub_BOMID_RSRC       nvarchar(18)  NULL ,
    Hub_BOMID_SQN        numeric(12) IDENTITY (1000,1) ,
    CONSTRAINT PK_BillOfMaterials_BillOfMaterialsID PRIMARY KEY  CLUSTERED (Hub_BOMID_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_BillOfMaterialsID ON Hub_BOMID
(
    BillOfMaterialsID     ASC
)
go


CREATE TABLE Sat_BOM
(
    StartDate            datetime  NOT NULL ,
    EndDate              datetime  NULL ,
    BOMLevel             smallint  NOT NULL ,
    PerAssemblyQty       decimal(8,2)  NOT NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_BOM_LDTS         datetime  NOT NULL ,
    Sat_BOM_RSRC         nvarchar(18)  NULL ,
    Sat_BOM_LEDTS        datetime  NULL ,
    Hub_BOMID_SQN        numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_BOM PRIMARY KEY  NONCLUSTERED (Hub_BOMID_SQN ASC,Sat_BOM_LDTS ASC),
     FOREIGN KEY (Hub_BOMID_SQN) REFERENCES Hub_BOMID(Hub_BOMID_SQN)
)
go


CREATE UNIQUE CLUSTERED INDEX AK_BillOfMaterials_ProductAssemblyID_ComponentID_StartDate ON Sat_BOM
(
    StartDate             ASC
)
go


CREATE TABLE Sat_StProv
(
    StateProvinceCode    nchar(3) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    CountryRegionCode    char(18) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    IsOnlyStateProvinceFlag bit  NOT NULL ,
    Name                 nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    TerritoryID          char(18)  NOT NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_StProv_LDTS      datetime  NOT NULL ,
    Sat_StProv_LEDTS     datetime  NULL ,
    Sat_StProv_RSRC      nvarchar(18)  NULL ,
    Hub_StProvID_SQN     numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_StProv PRIMARY KEY  CLUSTERED (Hub_StProvID_SQN ASC,Sat_StProv_LDTS ASC),
     FOREIGN KEY (Hub_StProvID_SQN) REFERENCES Hub_StProvID(Hub_StProvID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_StateProvince_Name ON Sat_StProv
(
    Name                  ASC
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_StateProvince_StateProvinceCode_CountryRegionCode ON Sat_StProv
(
    StateProvinceCode     ASC,
    CountryRegionCode     ASC
)
go


CREATE TABLE Lnk_StProvID_CntryRgnCd
(
    Lnk_StProvID_CntryRgnCd_LDTS datetime  NOT NULL ,
    Lnk_StProvID_CntryRgnCd_RSRC nvarchar(18)  NULL ,
    Lnk_StProvID_CntryRgnCd_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_StProvID_SQN     numeric(12)  NULL ,
    Hub_CntryRgnCd_SQN   numeric(12)  NULL ,
    CONSTRAINT XPKLnk_StProvID_CntryRgnID PRIMARY KEY  CLUSTERED (Lnk_StProvID_CntryRgnCd_SQN ASC),
     FOREIGN KEY (Hub_StProvID_SQN) REFERENCES Hub_StProvID(Hub_StProvID_SQN),
 FOREIGN KEY (Hub_CntryRgnCd_SQN) REFERENCES Hub_CntryRgnCd(Hub_CntryRgnCd_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Lnk_StProvID_CntryRgnID ON Lnk_StProvID_CntryRgnCd
(
    Hub_CntryRgnCd_SQN    ASC,
    Hub_StProvID_SQN      ASC
)
go


CREATE TABLE Sat_SaleTaxRt
(
    TaxType              tinyint  NOT NULL ,
    TaxRate              smallmoney  NOT NULL ,
    Name                 nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_SaleTaxRt_LDTS   datetime  NOT NULL ,
    Sat_SaleTaxRt_LEDTS  datetime  NULL ,
    Sat_SaleTaxRt_RSRC   nvarchar(18)  NULL ,
    Hub_SaleTaxRtID_SQN  numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_SaleTaxRt PRIMARY KEY  CLUSTERED (Hub_SaleTaxRtID_SQN ASC,Sat_SaleTaxRt_LDTS ASC),
     FOREIGN KEY (Hub_SaleTaxRtID_SQN) REFERENCES Hub_SaleTaxRtID(Hub_SaleTaxRtID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_SalesTaxRate_StateProvinceID_TaxType ON Sat_SaleTaxRt
(
    TaxType               ASC
)
go


CREATE TABLE Sat_SalePers
(
    TerritoryID          char(18)  NULL ,
    SalesQuota           money  NULL ,
    Bonus                money  NOT NULL ,
    CommissionPct        smallmoney  NOT NULL ,
    SalesYTD             money  NOT NULL ,
    SalesLastYear        money  NOT NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_SalePersLDTS     datetime  NOT NULL ,
    Sat_SalePersLEDTS    datetime  NULL ,
    Sat_SalePers_RSRC    nvarchar(18)  NULL ,
    Hub_SalePers_SQN     numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_SalePers PRIMARY KEY  CLUSTERED (Hub_SalePers_SQN ASC,Sat_SalePersLDTS ASC),
     FOREIGN KEY (Hub_SalePers_SQN) REFERENCES Hub_SalePers(Hub_SalePers_SQN)
)
go


CREATE TABLE Hub_SaleTerID
(
    TerritoryID          int  NOT NULL ,
    Hub_SaleTerID_LDTS   datetime  NOT NULL ,
    Hub_SaleTerID_RSRC   nvarchar(18)  NULL ,
    Hub_SaleTerID_SQN    numeric(12) IDENTITY (1000,1) ,
    CONSTRAINT PK_SalesTerritory_TerritoryID PRIMARY KEY  CLUSTERED (Hub_SaleTerID_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_SalesTerritoryID ON Hub_SaleTerID
(
    TerritoryID           ASC
)
go


CREATE TABLE Lnk_SalePers_SaleTerID
(
    Lnk_SalePers_SaleTerID_LDTS datetime  NOT NULL ,
    Lnk_SalePers_SaleTerID_RSRC nvarchar(18)  NULL ,
    Lnk_SalePers_SaleTerID_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_SalePers_SQN     numeric(12)  NULL ,
    Hub_SaleTerID_SQN    numeric(12)  NULL ,
    CONSTRAINT XPKLnk_SalePers_SaleTer PRIMARY KEY  CLUSTERED (Lnk_SalePers_SaleTerID_SQN ASC),
     FOREIGN KEY (Hub_SalePers_SQN) REFERENCES Hub_SalePers(Hub_SalePers_SQN),
 FOREIGN KEY (Hub_SaleTerID_SQN) REFERENCES Hub_SaleTerID(Hub_SaleTerID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Lnk_SalePers_SaleTer ON Lnk_SalePers_SaleTerID
(
    Hub_SalePers_SQN      ASC,
    Hub_SaleTerID_SQN     ASC
)
go


CREATE TABLE Sat_SaleTerHist
(
    StartDate            datetime  NOT NULL ,
    EndDate              datetime  NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_SaleTerHist_LDTS datetime  NOT NULL ,
    Sat_SaleTerHist_LEDTS datetime  NULL ,
    Sat_SaleTerHist_RSRC nvarchar(18)  NULL ,
    Lnk_SalePers_SaleTerID_SQN numeric(12)  NOT NULL ,
    CONSTRAINT PK_SalesTerritoryHistory_BusinessEntityID_StartDate_TerritoryID PRIMARY KEY  CLUSTERED (Lnk_SalePers_SaleTerID_SQN ASC,Sat_SaleTerHist_LDTS ASC),
     FOREIGN KEY (Lnk_SalePers_SaleTerID_SQN) REFERENCES Lnk_SalePers_SaleTerID(Lnk_SalePers_SaleTerID_SQN)
)
go


CREATE TABLE Sat_Store
(
    Name                 nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    Demographics         xml  NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_Store_LDTS       datetime  NOT NULL ,
    Sat_Store_LEDTS      datetime  NULL ,
    Sat_Store_RSRC       nvarchar(18)  NULL ,
    Hub_Store_SQN        numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_Store PRIMARY KEY  CLUSTERED (Hub_Store_SQN ASC,Sat_Store_LDTS ASC),
     FOREIGN KEY (Hub_Store_SQN) REFERENCES Hub_Store(Hub_Store_SQN)
)
go


CREATE TABLE Lnk_Cust_SaleTerID
(
    Lnk_Cust_SaleTerID_LDTS datetime  NOT NULL ,
    Lnk_Cust_SaleTerID_SRC nvarchar(18)  NULL ,
    Lnk_Cust_SaleTerID_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_CustID_SQN       numeric(12)  NULL ,
    Hub_SaleTerID_SQN    numeric(12)  NULL ,
    CONSTRAINT XPKLnk_Cust_SaleTerID PRIMARY KEY  CLUSTERED (Lnk_Cust_SaleTerID_SQN ASC),
     FOREIGN KEY (Hub_CustID_SQN) REFERENCES Hub_CustID(Hub_CustID_SQN),
 FOREIGN KEY (Hub_SaleTerID_SQN) REFERENCES Hub_SaleTerID(Hub_SaleTerID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Lnk_Cust_SaleTerID ON Lnk_Cust_SaleTerID
(
    Hub_CustID_SQN        ASC,
    Hub_SaleTerID_SQN     ASC
)
go


CREATE TABLE Sat_Crncy
(
    Name                 nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_Crncy_LDTS       datetime  NOT NULL ,
    Sat_Crncy_LEDTS      datetime  NULL ,
    Sat_Crncy_RSRC       nvarchar(18)  NULL ,
    Hub_CrncyCd_SQN      numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_Crncy PRIMARY KEY  CLUSTERED (Hub_CrncyCd_SQN ASC,Sat_Crncy_LDTS ASC),
     FOREIGN KEY (Hub_CrncyCd_SQN) REFERENCES Hub_CrncyCd(Hub_CrncyCd_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Currency_Name ON Sat_Crncy
(
    Name                  ASC
)
go


CREATE TABLE Lnk_SOrdNum_SalePers
(
    Lnk_SOrdNum_SalePers_LDTS datetime  NOT NULL ,
    Lnk_SOrdNum_SalePers_RSRC nvarchar(18)  NULL ,
    Lnk_SOrdNum_SalePers_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_SalePers_SQN     numeric(12)  NULL ,
    Hub_SOrdNum_SQN      numeric(12)  NULL ,
    CONSTRAINT XPKLnk_SOrdID_SalePers PRIMARY KEY  CLUSTERED (Lnk_SOrdNum_SalePers_SQN ASC),
     FOREIGN KEY (Hub_SalePers_SQN) REFERENCES Hub_SalePers(Hub_SalePers_SQN),
 FOREIGN KEY (Hub_SOrdNum_SQN) REFERENCES Hub_SOrdNum(Hub_SOrdNum_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Lnk_SOrdID_SalePers ON Lnk_SOrdNum_SalePers
(
    Hub_SalePers_SQN      ASC,
    Hub_SOrdNum_SQN       ASC
)
go


CREATE TABLE Sat_SalePersQuotaHist
(
    QuotaDate            datetime  NOT NULL ,
    SalesQuota           money  NOT NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_SalePersQuotaHist_LDTS datetime  NOT NULL ,
    Sat_SalePersQuotaHist_LEDTS datetime  NULL ,
    Sat_SalePersQuotaHist_RSRC nvarchar(18)  NULL ,
    Hub_SalePers_SQN     numeric(12)  NOT NULL ,
    CONSTRAINT PK_SalesPersonQuotaHistory_BusinessEntityID_QuotaDate PRIMARY KEY  CLUSTERED (Hub_SalePers_SQN ASC,Sat_SalePersQuotaHist_LDTS ASC),
     FOREIGN KEY (Hub_SalePers_SQN) REFERENCES Hub_SalePers(Hub_SalePers_SQN)
)
go


CREATE TABLE Hub_CrncyRtID
(
    CurrencyRateID       int  NOT NULL ,
    Hub_CrncyRtID_LDTS   datetime  NOT NULL ,
    Hub_CrncyRtID_RSRC   nvarchar(18)  NULL ,
    Hub_CrncyRtID_SQN    numeric(12) IDENTITY (1000,1) ,
    CONSTRAINT PK_CurrencyRate_CurrencyRateID PRIMARY KEY  CLUSTERED (Hub_CrncyRtID_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_CurrencyRate ON Hub_CrncyRtID
(
    CurrencyRateID        ASC
)
go


CREATE TABLE Sat_CrncyRt
(
    CurrencyRateDate     datetime  NOT NULL ,
    AverageRate          money  NOT NULL ,
    EndOfDayRate         money  NOT NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_CrncyRt_LDTS     datetime  NOT NULL ,
    Sat_CrncyRt_LEDTS    datetime  NULL ,
    Sat_CrncyRt_RSRC     nvarchar(18)  NULL ,
    Hub_CrncyRtID_SQN    numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_CrncyRt PRIMARY KEY  CLUSTERED (Hub_CrncyRtID_SQN ASC,Sat_CrncyRt_LDTS ASC),
     FOREIGN KEY (Hub_CrncyRtID_SQN) REFERENCES Hub_CrncyRtID(Hub_CrncyRtID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_CurrencyRate_CurrencyRateDate_FromCurrencyCode_ToCurrencyCode ON Sat_CrncyRt
(
    CurrencyRateDate      ASC
)
go


CREATE TABLE Sat_BusEntID
(
    ModifiedDate         datetime  NOT NULL ,
    Sat_BusEntID_LDTS    datetime  NOT NULL ,
    Sat_BusEntID_LEDTS   datetime  NULL ,
    Sat_BusEntID_RSRC    nvarchar(18)  NULL ,
    Hub_BusEntID_SQN     numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_BusEntID PRIMARY KEY  CLUSTERED (Hub_BusEntID_SQN ASC,Sat_BusEntID_LDTS ASC),
     FOREIGN KEY (Hub_BusEntID_SQN) REFERENCES Hub_BusEntID(Hub_BusEntID_SQN)
)
go


CREATE TABLE Lnk_EmpID_PersID
(
    Lnk_EmpID_PersID_LDTS datetime  NOT NULL ,
    Lnk_EmpID_PersID_RSRC nvarchar(18)  NULL ,
    Lnk_EmpID_PersID_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_EmpID_SQN        numeric(12)  NULL ,
    Hub_PersID_SQN       numeric(12)  NULL ,
    CONSTRAINT XPKLnk_EmpID_PersID PRIMARY KEY  CLUSTERED (Lnk_EmpID_PersID_SQN ASC),
     FOREIGN KEY (Hub_EmpID_SQN) REFERENCES Hub_EmpID(Hub_EmpID_SQN),
 FOREIGN KEY (Hub_PersID_SQN) REFERENCES Hub_PersID(Hub_PersID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Lnk_EmpID_PersID ON Lnk_EmpID_PersID
(
    Hub_EmpID_SQN         ASC,
    Hub_PersID_SQN        ASC
)
go


CREATE TABLE Lnk_CustID_Store
(
    Lnk_CustID_Store_LDTS datetime  NOT NULL ,
    Lnk_CustID_Store_RSRC nvarchar(18)  NULL ,
    Lnk_CustID_Store_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_Store_SQN        numeric(12)  NULL ,
    Hub_CustID_SQN       numeric(12)  NULL ,
    CONSTRAINT XPKLnk_CustID_Store PRIMARY KEY  CLUSTERED (Lnk_CustID_Store_SQN ASC),
     FOREIGN KEY (Hub_Store_SQN) REFERENCES Hub_Store(Hub_Store_SQN),
 FOREIGN KEY (Hub_CustID_SQN) REFERENCES Hub_CustID(Hub_CustID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Lnk_CustID_Store ON Lnk_CustID_Store
(
    Hub_Store_SQN         ASC,
    Hub_CustID_SQN        ASC
)
go


CREATE TABLE Lnk_PersID_CustID
(
    Lnk_PersID_CustID_LDTS datetime  NOT NULL ,
    Lnk_PersID_CustID_RSRC nvarchar(18)  NULL ,
    Lnk_PersID_CustID_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_CustID_SQN       numeric(12)  NULL ,
    Hub_PersID_SQN       numeric(12)  NULL ,
    CONSTRAINT XPKLnk_PersID_CustID PRIMARY KEY  CLUSTERED (Lnk_PersID_CustID_SQN ASC),
     FOREIGN KEY (Hub_CustID_SQN) REFERENCES Hub_CustID(Hub_CustID_SQN),
 FOREIGN KEY (Hub_PersID_SQN) REFERENCES Hub_PersID(Hub_PersID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Lnk_PersID_CustID ON Lnk_PersID_CustID
(
    Hub_CustID_SQN        ASC,
    Hub_PersID_SQN        ASC
)
go


CREATE TABLE Hub_AddTypID
(
    AddressTypeID        int  NOT NULL ,
    Hub_AddTypID_LDTS    datetime  NOT NULL ,
    Hub_AddTypID_RSRC    nvarchar(18)  NULL ,
    Hub_AddTypID_SQN     numeric(12) IDENTITY (1000,1) ,
    CONSTRAINT PK_AddressType_AddressTypeID PRIMARY KEY  CLUSTERED (Hub_AddTypID_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_AddressTypeID ON Hub_AddTypID
(
    AddressTypeID         ASC
)
go


CREATE TABLE Sat_AddTyp
(
    Name                 nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_AddTyp_LDTS      datetime  NOT NULL ,
    Sat_AddTyp_LEDTS     datetime  NULL ,
    Sat_AddTyp_RSRC      nvarchar(18)  NULL ,
    Hub_AddTypID_SQN     numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_AddTyp PRIMARY KEY  CLUSTERED (Hub_AddTypID_SQN ASC,Sat_AddTyp_LDTS ASC),
     FOREIGN KEY (Hub_AddTypID_SQN) REFERENCES Hub_AddTypID(Hub_AddTypID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_AddressType_Name ON Sat_AddTyp
(
    Name                  ASC
)
go


CREATE TABLE Sat_SaleTer
(
    Name                 nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    CountryRegionCode    nvarchar(3) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    [Group]                nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    SalesYTD             money  NOT NULL ,
    SalesLastYear        money  NOT NULL ,
    CostYTD              money  NOT NULL ,
    CostLastYear         money  NOT NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_SaleTer_LDTS     datetime  NOT NULL ,
    Sat_SaleTer_RSRC     nvarchar(18)  NULL ,
    Hub_SaleTerID_SQN    numeric(12)  NOT NULL ,
    Sat_SaleTer_LEDTS    datetime  NULL ,
    CONSTRAINT PK_Sat_SaleTer PRIMARY KEY  CLUSTERED (Hub_SaleTerID_SQN ASC,Sat_SaleTer_LDTS ASC),
     FOREIGN KEY (Hub_SaleTerID_SQN) REFERENCES Hub_SaleTerID(Hub_SaleTerID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_SalesTerritory_Name ON Sat_SaleTer
(
    Name                  ASC
)
go


CREATE TABLE Lnk_ProdNum_UntMsrCd
(
    Lnk_ProdNum_UntMsrCd_LDTS datetime  NOT NULL ,
    Lnk_ProdNum_UntMsrCd_RSRC nvarchar(18)  NULL ,
    Lnk_ProdNum_UntMsrCd_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_UntMsrCd_Wt_SQN  numeric(12)  NULL ,
    Hub_ProdNum_SQN      numeric(12)  NULL ,
    Hub_UntMsrCd_Size_SQN numeric(12)  NULL ,
    CONSTRAINT XPKLnk_VendNum_UntMsrCd PRIMARY KEY  CLUSTERED (Lnk_ProdNum_UntMsrCd_SQN ASC),
     FOREIGN KEY (Hub_UntMsrCd_Wt_SQN) REFERENCES Hub_UntMsrCd(Hub_UntMsrCd_SQN),
 FOREIGN KEY (Hub_ProdNum_SQN) REFERENCES Hub_ProdNum(Hub_ProdNum_SQN),
 FOREIGN KEY (Hub_UntMsrCd_Size_SQN) REFERENCES Hub_UntMsrCd(Hub_UntMsrCd_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Lnk_VendNum_UntMsrCd ON Lnk_ProdNum_UntMsrCd
(
    Hub_UntMsrCd_Wt_SQN   ASC,
    Hub_ProdNum_SQN       ASC,
    Hub_UntMsrCd_Size_SQN  ASC
)
go


CREATE TABLE Sat_UntMsr
(
    Name                 nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_UntMsr_LDTS      datetime  NOT NULL ,
    Sat_UntMsr_LEDTS     datetime  NULL ,
    Sat_UntMsr_RSRC      nvarchar(18)  NULL ,
    Hub_UntMsrCd_SQN     numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_UntMsr PRIMARY KEY  CLUSTERED (Sat_UntMsr_LDTS ASC,Hub_UntMsrCd_SQN ASC),
     FOREIGN KEY (Hub_UntMsrCd_SQN) REFERENCES Hub_UntMsrCd(Hub_UntMsrCd_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_UnitMeasure_Name ON Sat_UntMsr
(
    Name                  ASC
)
go


CREATE TABLE Lnk_CrncyCd_CrncyRtID
(
    Lnk_CrncyCd_CrncyRtID_LDTS datetime  NOT NULL ,
    Lnk_CrncyCd_CrncyRtID_RSRC nvarchar(18)  NULL ,
    Lnk_CrncyCd_CrncyRtID_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_CrncyRtID_SQN    numeric(12)  NULL ,
    Hub_CrncyCd_From_SQN numeric(12)  NULL ,
    Hub_CrncyCd_To_SQN   numeric(12)  NULL ,
    CONSTRAINT XPKLnk_CrncyCd_CrncyRtID PRIMARY KEY  CLUSTERED (Lnk_CrncyCd_CrncyRtID_SQN ASC),
     FOREIGN KEY (Hub_CrncyRtID_SQN) REFERENCES Hub_CrncyRtID(Hub_CrncyRtID_SQN),
 FOREIGN KEY (Hub_CrncyCd_From_SQN) REFERENCES Hub_CrncyCd(Hub_CrncyCd_SQN),
 FOREIGN KEY (Hub_CrncyCd_To_SQN) REFERENCES Hub_CrncyCd(Hub_CrncyCd_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Lnk_CrncyCd_CrncyRtID ON Lnk_CrncyCd_CrncyRtID
(
    Hub_CrncyRtID_SQN     ASC,
    Hub_CrncyCd_From_SQN  ASC,
    Hub_CrncyCd_To_SQN    ASC
)
go


CREATE TABLE Lnk_SOrdNum_CrncyRtID
(
    Lnk_SOrdNum_CrncyRtID_LDTS datetime  NOT NULL ,
    Lnk_SOrdNum_CrncyRtID_RSRC nvarchar(18)  NULL ,
    Lnk_SOrdNum_CrncyRtID_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_CrncyRtID_SQN    numeric(12)  NULL ,
    Hub_SOrdNum_SQN      numeric(12)  NULL ,
    CONSTRAINT XPKLnk_SOrdNum_CrncyRtID PRIMARY KEY  CLUSTERED (Lnk_SOrdNum_CrncyRtID_SQN ASC),
     FOREIGN KEY (Hub_CrncyRtID_SQN) REFERENCES Hub_CrncyRtID(Hub_CrncyRtID_SQN),
 FOREIGN KEY (Hub_SOrdNum_SQN) REFERENCES Hub_SOrdNum(Hub_SOrdNum_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Lnk_SOrdNum_CrncyRtID ON Lnk_SOrdNum_CrncyRtID
(
    Hub_CrncyRtID_SQN     ASC,
    Hub_SOrdNum_SQN       ASC
)
go


CREATE TABLE Sat_CntryRgn
(
    Name                 nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_CntryRgn_LDTS    datetime  NOT NULL ,
    Sat_CntryRgn_RSRC    nvarchar(18)  NULL ,
    Sat_CntryRgn_LEDTS   datetime  NULL ,
    Hub_CntryRgnCd_SQN   numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_CntryRgn PRIMARY KEY  CLUSTERED (Hub_CntryRgnCd_SQN ASC,Sat_CntryRgn_LDTS ASC),
     FOREIGN KEY (Hub_CntryRgnCd_SQN) REFERENCES Hub_CntryRgnCd(Hub_CntryRgnCd_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_CountryRegion_Name ON Sat_CntryRgn
(
    Name                  ASC
)
go


CREATE TABLE Lnk_SaleTerID_StProvID
(
    Lnk_SaleTerID_StProvID_LDTS datetime  NOT NULL ,
    Lnk_SaleTerID_StProvID_RSRC nvarchar(18)  NULL ,
    Lnk_SaleTerID_StProvID_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_SaleTerID_SQN    numeric(12)  NULL ,
    Hub_StProvID_SQN     numeric(12)  NULL ,
    CONSTRAINT XPKLnk_SaleTerID_StProvID PRIMARY KEY  CLUSTERED (Lnk_SaleTerID_StProvID_SQN ASC),
     FOREIGN KEY (Hub_SaleTerID_SQN) REFERENCES Hub_SaleTerID(Hub_SaleTerID_SQN),
 FOREIGN KEY (Hub_StProvID_SQN) REFERENCES Hub_StProvID(Hub_StProvID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Lnk_SaleTerID_StProvID ON Lnk_SaleTerID_StProvID
(
    Hub_SaleTerID_SQN     ASC,
    Hub_StProvID_SQN      ASC
)
go


CREATE TABLE Lnk_CustID_SOrdNum
(
    Lnk_CustID_SOrdNum_LDTS datetime  NOT NULL ,
    Lnk_CustID_SOrdNum_RSRC nvarchar(18)  NULL ,
    Lnk_CustID_SOrdNum_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_CustID_SQN       numeric(12)  NULL ,
    Hub_SOrdNum_SQN      numeric(12)  NULL ,
    CONSTRAINT XPKLnk_CustID_SOrdNum PRIMARY KEY  CLUSTERED (Lnk_CustID_SOrdNum_SQN ASC),
     FOREIGN KEY (Hub_CustID_SQN) REFERENCES Hub_CustID(Hub_CustID_SQN),
 FOREIGN KEY (Hub_SOrdNum_SQN) REFERENCES Hub_SOrdNum(Hub_SOrdNum_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Lnk_CustID_SOrdNum ON Lnk_CustID_SOrdNum
(
    Hub_SOrdNum_SQN       ASC,
    Hub_CustID_SQN        ASC
)
go


CREATE TABLE Sat_Add
(
    AddressLine1         nvarchar(60) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    AddressLine2         nvarchar(60) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL ,
    City                 nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    StateProvinceID      char(18)  NOT NULL ,
    PostalCode           nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    SpatialLocation      char(18)  NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_Add_LDTS         datetime  NOT NULL ,
    Sat_Add_LEDTS        datetime  NULL ,
    Sat_Add_RSRC         nvarchar(18)  NULL ,
    Hub_AddID_SQN        numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_Add PRIMARY KEY  CLUSTERED (Hub_AddID_SQN ASC,Sat_Add_LDTS ASC),
     FOREIGN KEY (Hub_AddID_SQN) REFERENCES Hub_AddID(Hub_AddID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX IX_Address_AddressLine1_AddressLine2_City_StateProvinceID_Postal ON Sat_Add
(
    AddressLine1          ASC,
    AddressLine2          ASC,
    City                  ASC,
    StateProvinceID       ASC,
    PostalCode            ASC
)
go


CREATE TABLE Lnk_BusEntID_AddID_AddTypID
(
    Lnk_BusEntID_AddID_AddTypID_LDTS datetime  NOT NULL ,
    Lnk_BusEntID_AddID_AddTypID_RSRC nvarchar(18)  NULL ,
    Lnk_BusEntID_AddID_AddTypID_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_BusEntID_SQN     numeric(12)  NULL ,
    Hub_AddTypID_SQN     numeric(12)  NULL ,
    Hub_AddID_SQN        numeric(12)  NULL ,
    CONSTRAINT XPKLnk_BusEntID_AddID PRIMARY KEY  CLUSTERED (Lnk_BusEntID_AddID_AddTypID_SQN ASC),
     FOREIGN KEY (Hub_BusEntID_SQN) REFERENCES Hub_BusEntID(Hub_BusEntID_SQN),
 FOREIGN KEY (Hub_AddTypID_SQN) REFERENCES Hub_AddTypID(Hub_AddTypID_SQN),
 FOREIGN KEY (Hub_AddID_SQN) REFERENCES Hub_AddID(Hub_AddID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Lnk_BusEntID_AddID ON Lnk_BusEntID_AddID_AddTypID
(
    Hub_BusEntID_SQN      ASC,
    Hub_AddTypID_SQN      ASC,
    Hub_AddID_SQN         ASC
)
go


CREATE TABLE Sat_BusEntID_AddID_AddTypID
(
    ModifiedDate         datetime  NOT NULL ,
    Sat_BusEntID_AddID_AddTypID_LDTS datetime  NOT NULL ,
    Sat_BusEntID_AddID_AddTypID_LEDTS datetime  NULL ,
    Sat_BusEntID_AddID_AddTypID_RSRC nvarchar(18)  NULL ,
    Lnk_BusEntID_AddID_AddTypID_SQN numeric(12)  NOT NULL ,
    CONSTRAINT PK_BusinessEntityAddress_BusinessEntityID_AddressID_AddressTypeI PRIMARY KEY  CLUSTERED (Lnk_BusEntID_AddID_AddTypID_SQN ASC,Sat_BusEntID_AddID_AddTypID_LDTS ASC),
     FOREIGN KEY (Lnk_BusEntID_AddID_AddTypID_SQN) REFERENCES Lnk_BusEntID_AddID_AddTypID(Lnk_BusEntID_AddID_AddTypID_SQN)
)
go


CREATE TABLE Lnk_ProdNum_BOMID
(
    Lnk_ProdNum_BOMID_LDTS datetime  NOT NULL ,
    Lnk_ProdNum_BOMID_RSRC nvarchar(18)  NULL ,
    Lnk_ProdNum_BOMID_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_ProdNum_Comp_SQN numeric(12)  NULL ,
    Hub_ProdNum_Asmbly_SQN numeric(12)  NULL ,
    Hub_BOMID_SQN        numeric(12)  NULL ,
    CONSTRAINT XPKLnk_BOM_Heir PRIMARY KEY  CLUSTERED (Lnk_ProdNum_BOMID_SQN ASC),
     FOREIGN KEY (Hub_ProdNum_Comp_SQN) REFERENCES Hub_ProdNum(Hub_ProdNum_SQN),
 FOREIGN KEY (Hub_ProdNum_Asmbly_SQN) REFERENCES Hub_ProdNum(Hub_ProdNum_SQN),
 FOREIGN KEY (Hub_BOMID_SQN) REFERENCES Hub_BOMID(Hub_BOMID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Lnk_BOM_Heir ON Lnk_ProdNum_BOMID
(
    Hub_ProdNum_Comp_SQN  ASC,
    Hub_ProdNum_Asmbly_SQN  ASC,
    Hub_BOMID_SQN         ASC
)
go


CREATE TABLE Hub_CntTypID
(
    ContactTypeID        int  NOT NULL ,
    Hub_CntTypID_LDTS    datetime  NOT NULL ,
    Hub_CntTypID_RSRC    nvarchar(18)  NULL ,
    Hub_CntTypID_SQN     numeric(12) IDENTITY (1000,1) ,
    CONSTRAINT PK_ContactType_ContactTypeID PRIMARY KEY  CLUSTERED (Hub_CntTypID_SQN ASC)
)
go


CREATE UNIQUE NONCLUSTERED INDEX BK_ContactTypeID ON Hub_CntTypID
(
    ContactTypeID         ASC
)
go


CREATE TABLE Sat_CntTyp
(
    Name                 nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  NOT NULL ,
    ModifiedDate         datetime  NOT NULL ,
    Sat_CntTyp_LDTS      datetime  NOT NULL ,
    Sat_CntTyp_LEDTS     datetime  NULL ,
    Sat_CntTyp_RSRC      nvarchar(18)  NULL ,
    Hub_CntTypID_SQN     numeric(12)  NOT NULL ,
    CONSTRAINT PK_Sat_CntTyp PRIMARY KEY  CLUSTERED (Hub_CntTypID_SQN ASC,Sat_CntTyp_LDTS ASC),
     FOREIGN KEY (Hub_CntTypID_SQN) REFERENCES Hub_CntTypID(Hub_CntTypID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_ContactType_Name ON Sat_CntTyp
(
    Name                  ASC
)
go


CREATE TABLE Lnk_PersID_BusEntID_CntTypID
(
    Lnk_PersID_BusEntID_CntTypID_LDTS datetime  NOT NULL ,
    Lnk_PersID_BusEntID_CntTypID_RSRC nvarchar(18)  NULL ,
    Lnk_PersID_BusEntID_CntTypID_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_CntTypID_SQN     numeric(12)  NULL ,
    Hub_BusEntID_SQN     numeric(12)  NULL ,
    Hub_PersID_SQN       numeric(12)  NULL ,
    CONSTRAINT XPKLnk_PersID_BusEntID_CntTypID PRIMARY KEY  CLUSTERED (Lnk_PersID_BusEntID_CntTypID_SQN ASC),
     FOREIGN KEY (Hub_CntTypID_SQN) REFERENCES Hub_CntTypID(Hub_CntTypID_SQN),
 FOREIGN KEY (Hub_BusEntID_SQN) REFERENCES Hub_BusEntID(Hub_BusEntID_SQN),
 FOREIGN KEY (Hub_PersID_SQN) REFERENCES Hub_PersID(Hub_PersID_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Lnk_PersID_BusEntID_CntTypID ON Lnk_PersID_BusEntID_CntTypID
(
    Hub_CntTypID_SQN      ASC,
    Hub_BusEntID_SQN      ASC,
    Hub_PersID_SQN        ASC
)
go


CREATE TABLE Sat_BusEnt_Cnt
(
    ModifiedDate         datetime  NOT NULL ,
    Sat_BusEnt_Cnt_LDTS  datetime  NOT NULL ,
    Sat_BusEnt_Cnt_LEDTS datetime  NULL ,
    Sat_BusEnt_Cnt_RSRC  nvarchar(18)  NULL ,
    Lnk_PersID_BusEntID_CntTypID_SQN numeric(12)  NOT NULL ,
    CONSTRAINT PK_BusinessEntityContact_BusinessEntityID_PersonID_ContactTypeID PRIMARY KEY  CLUSTERED (Lnk_PersID_BusEntID_CntTypID_SQN ASC,Sat_BusEnt_Cnt_LDTS ASC),
     FOREIGN KEY (Lnk_PersID_BusEntID_CntTypID_SQN) REFERENCES Lnk_PersID_BusEntID_CntTypID(Lnk_PersID_BusEntID_CntTypID_SQN)
)
go


CREATE TABLE Lnk_SOrdNum_SaleTerID
(
    Lnk_SOrdNum_SaleTerID_LDTS datetime  NOT NULL ,
    Lnk_SOrdNum_SaleTerID_RSRC nvarchar(18)  NULL ,
    Lnk_SOrdNum_SaleTerID_SQN numeric(12) IDENTITY (1000,1) ,
    Hub_SaleTerID_SQN    numeric(12)  NULL ,
    Hub_SOrdNum_SQN      numeric(12)  NULL ,
    CONSTRAINT XPKLnk_SOrdNum_SaleTerID PRIMARY KEY  CLUSTERED (Lnk_SOrdNum_SaleTerID_SQN ASC),
     FOREIGN KEY (Hub_SaleTerID_SQN) REFERENCES Hub_SaleTerID(Hub_SaleTerID_SQN),
 FOREIGN KEY (Hub_SOrdNum_SQN) REFERENCES Hub_SOrdNum(Hub_SOrdNum_SQN)
)
go


CREATE UNIQUE NONCLUSTERED INDEX AK_Lnk_SOrdNum_SaleTerID ON Lnk_SOrdNum_SaleTerID
(
    Hub_SaleTerID_SQN     ASC,
    Hub_SOrdNum_SQN       ASC
)
go