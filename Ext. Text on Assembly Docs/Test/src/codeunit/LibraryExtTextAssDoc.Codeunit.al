codeunit 76469 "Library - Ext Text Ass Doc FLX"
{
    #region creator methods
    procedure CreateUnitOfMeasure()
    var
        UnitOfMeasure: Record "Unit of Measure";
        LibraryInventory: Codeunit "Library - Inventory 2 FLX";
    begin
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
    end;

    procedure CreateItemWithNoExtendedText(): Code[20]
    var
        Item: Record Item;
        LibraryInventory: Codeunit "Library - Inventory 2 FLX";
    begin
        LibraryInventory.CreateItem(Item);
        exit(Item."No.");
    end;

    procedure CreateItemUnitOfMeasureCode(ItemNo: Code[20]): Code[10]
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        LibraryInventory: Codeunit "Library - Inventory 2 FLX";
    begin
        LibraryInventory.CreateItemUnitOfMeasureCode(ItemUnitOfMeasure, ItemNo, 1);
        exit(ItemUnitOfMeasure.Code);
    end;

    procedure CreateResourceWithNoExtendedText(): Code[20]
    var
        Resource: Record Resource;
        LibraryResource: Codeunit "Library - Resource 2 FLX";
    begin
        LibraryResource.CreateResourceNew(Resource);
        exit(Resource."No.");
    end;

    procedure CreateResourceUnitOfMeasureCode(ResourceNo: Code[20]): Code[10]
    var
        ResourceUnitOfMeasure: Record "Resource Unit of Measure";
        UnitOfMeasure: Record "Unit of Measure";
        LibraryInventory: Codeunit "Library - Inventory 2 FLX";
    begin
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);

        ResourceUnitOfMeasure.Init();
        ResourceUnitOfMeasure.Validate("Resource No.", ResourceNo);
        ResourceUnitOfMeasure.Validate(Code, UnitOfMeasure.Code);
        ResourceUnitOfMeasure.Validate("Qty. per Unit of Measure", 1);
        ResourceUnitOfMeasure.Insert(true);
    end;

    procedure CreateStandardTextWithNoExtendedText(): Code[20]
    var
        StandardText: Record "Standard Text";
        LibrarySales: Codeunit "Library - Sales 2 FLX";
    begin
        LibrarySales.CreateStandardText(StandardText);
        exit(StandardText.Code);
    end;

    procedure CreateItemWithExtendedText(AutomaticExtTextsEnabled: Boolean; AssemblyDocumentType: Enum "Assembly Document Type"; ExtendedTextEnabled: Boolean): Code[20]
    var
        Item: Record Item;
        LibraryInventory: Codeunit "Library - Inventory 2 FLX";
    begin
        LibraryInventory.CreateItem(Item);
        Item."Automatic Ext. Texts" := AutomaticExtTextsEnabled;
        Item.Modify();

        CreateExtendedText("Extended Text Table Name"::Item, Item."No.", AssemblyDocumentType, ExtendedTextEnabled);
        exit(Item."No.");
    end;

    procedure CreateResourceWithExtendedText(AutomaticExtTextsEnabled: Boolean; AssemblyDocumentType: Enum "Assembly Document Type"; ExtendedTextEnabled: Boolean): Code[20]
    var
        Resource: Record Resource;
        LibraryResource: Codeunit "Library - Resource 2 FLX";
    begin
        LibraryResource.CreateResourceNew(Resource);
        Resource."Automatic Ext. Texts" := AutomaticExtTextsEnabled;
        Resource.Modify();

        CreateExtendedText("Extended Text Table Name"::Resource, Resource."No.", AssemblyDocumentType, ExtendedTextEnabled);
        exit(Resource."No.");
    end;

    procedure CreateStandardTextWithExtendedText(AssemblyDocumentType: Enum "Assembly Document Type"; ExtendedTextEnabled: Boolean): Code[20]
    var
        StandardText: Record "Standard Text";
        LibrarySales: Codeunit "Library - Sales 2 FLX";
    begin
        LibrarySales.CreateStandardText(StandardText);

        CreateExtendedText("Extended Text Table Name"::"Standard Text", StandardText.Code, AssemblyDocumentType, ExtendedTextEnabled);
        exit(StandardText.Code);
    end;

    local procedure CreateExtendedText(TableName: Enum "Extended Text Table Name"; No: Code[20]; AssemblyDocumentType: Enum "Assembly Document Type"; ExtendedTextEnabled: Boolean)
    var
        ExtendedTextHeader: Record "Extended Text Header";
        ExtendedTextLine: Record "Extended Text Line";
        LibraryService: Codeunit "Library - Service 2 FLX";
        LibraryRandom: Codeunit "Library - Random 2 FLX";
    begin
        CreateExtendedTextHeader(ExtendedTextHeader, TableName, No);

        ExtendedTextHeader."Assembly Order FLX" := false;
        ExtendedTextHeader."Assembly Quote FLX" := false;
        ExtendedTextHeader."Assembly Blanket Order FLX" := false;

        case AssemblyDocumentType of
            AssemblyDocumentType::Order:
                ExtendedTextHeader."Assembly Order FLX" := ExtendedTextEnabled;
            AssemblyDocumentType::Quote:
                ExtendedTextHeader."Assembly Quote FLX" := ExtendedTextEnabled;
            AssemblyDocumentType::"Blanket Order":
                ExtendedTextHeader."Assembly Blanket Order FLX" := ExtendedTextEnabled;
        end;

        ExtendedTextHeader.Modify();
        LibraryService.CreateExtendedTextLineItem(ExtendedTextLine, ExtendedTextHeader);
        ExtendedTextLine.Text := LibraryRandom.RandText(MaxStrLen(ExtendedTextLine.Text));
        ExtendedTextLine.Modify();
    end;

    local procedure CreateExtendedTextHeader(var ExtendedTextHeader: Record "Extended Text Header"; TableName: Enum "Extended Text Table Name"; No: Code[20])
    begin
        ExtendedTextHeader.Init();
        ExtendedTextHeader.Validate("Table Name", TableName);
        ExtendedTextHeader.Validate("No.", No);
        ExtendedTextHeader.Insert(true);
    end;

    procedure CreateAssemblyDocument(AssemblyDocumentType: Enum "Assembly Document Type"): Code[20]
    var
        AssemblyHeader: Record "Assembly Header";
    begin
        AssemblyHeader."Document Type" := AssemblyDocumentType;
        AssemblyHeader.Insert(true);
        exit(AssemblyHeader."No.");
    end;

    procedure CreateBlanketAssemblyOrder(var AssemblyHeader: Record "Assembly Header"; DueDate: Date; ParentItemNo: Code[20]; LocationCode: Code[10]; Quantity: Decimal): Code[20]
    var
        LibraryAssembly: Codeunit "Library - Assembly 2 FLX";
    begin
        Clear(AssemblyHeader);
        AssemblyHeader."Document Type" := AssemblyHeader."Document Type"::"Blanket Order";
        AssemblyHeader.Insert(true);
        AssemblyHeader.Validate("Item No.", ParentItemNo);
        AssemblyHeader.Validate("Location Code", LocationCode);
        AssemblyHeader.Validate("Due Date", DueDate);
        AssemblyHeader.Validate(Quantity, Quantity);
        AssemblyHeader.Modify(true);

        exit(AssemblyHeader."No.");
    end;
    #endregion creator methods

    #region user action methods
    procedure DeleteLineFromAssemblyDocument(AssemblyDocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20]; LineType: Enum "BOM Component Type"; No: Code[20])
    var
        AssemblyLine: Record "Assembly Line";
    begin
        FindAssemblyLine(AssemblyDocumentType, AssemblyDocNo, LineType, No, AssemblyLine);
        AssemblyLine.Delete(true);
    end;

    procedure InsertExtendedText(AssemblyDocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20]; LineType: Enum "BOM Component Type"; No: Code[20])
    var
        AssemblyLine: Record "Assembly Line";
        TransferExtendedText: Codeunit "Transfer Extended Text FLX";
    begin
        FindAssemblyLine(AssemblyDocumentType, AssemblyDocNo, LineType, No, AssemblyLine);

        TransferExtendedText.AssemblyCheckIfAnyExtText(AssemblyLine, true);
        TransferExtendedText.InsertAssemblyExtText(AssemblyLine);
    end;

    procedure FindAssemblyLine(AssemblyDocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20]; LineType: Enum "BOM Component Type"; No: Code[20]; var AssemblyLine: Record "Assembly Line")
    begin
        SetAssemblyLineFilter(AssemblyDocumentType, AssemblyDocNo, LineType, No, AssemblyLine);
        AssemblyLine.FindFirst();
    end;

    procedure SetAssemblyLineFilter(DocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20]; LineType: Enum "BOM Component Type"; No: Code[20]; var AssemblyLine: Record "Assembly Line")
    var
        AssemblyHeader: Record "Assembly Header";
    begin
        AssemblyLine.SetRange("Document Type", DocumentType);
        AssemblyLine.SetRange("Document No.", AssemblyDocNo);
        AssemblyLine.SetRange(Type, LineType);
        AssemblyLine.SetRange("No.", No);
    end;
    #endregion user action methods

    #region verification methods
    procedure VerifyExtendedTextLinesAreAddedToAssemblyDocument(AssemblyDocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20]; LineType: Enum "BOM Component Type"; No: Code[20]; NoOfExtendedTextLines: Integer)
    var
        AssemblyHeader: Record "Assembly Header";
        AssemblyLine: Record "Assembly Line";
        ExtendedTextHeader: Record "Extended Text Header";
        ExtendedTextLine: Record "Extended Text Line";
    begin
        case LineType of
            LineType::" ":
                begin
                    ExtendedTextHeader.SetRange(ExtendedTextHeader."Table Name", ExtendedTextHeader."Table Name"::"Standard Text");
                    ExtendedTextLine.SetRange("Table Name", ExtendedTextLine."Table Name"::"Standard Text");
                end;
            LineType::Item:
                begin
                    ExtendedTextHeader.SetRange(ExtendedTextHeader."Table Name", ExtendedTextHeader."Table Name"::Item);
                    ExtendedTextLine.SetRange("Table Name", ExtendedTextLine."Table Name"::Item);
                end;
            LineType::Resource:
                begin
                    ExtendedTextHeader.SetRange(ExtendedTextHeader."Table Name", ExtendedTextHeader."Table Name"::Resource);
                    ExtendedTextLine.SetRange("Table Name", ExtendedTextLine."Table Name"::Resource);
                end;
        end;
        ExtendedTextHeader.SetRange("No.", No);
        ExtendedTextHeader.FindFirst();

        ExtendedTextLine.SetRange("No.", No);

        AssemblyHeader.Get(AssemblyDocumentType, AssemblyDocNo);
        AssemblyLine.SetRange("Document Type", AssemblyDocumentType);
        AssemblyLine.SetRange("Document No.", AssemblyDocNo);
        AssemblyLine.SetRange("No.", '');
        AssemblyLine.SetRange(Type, AssemblyLine.Type::" ");

        Assert.RecordCount(ExtendedTextLine, NoOfExtendedTextLines);
        Assert.RecordCount(AssemblyLine, NoOfExtendedTextLines);

        AssemblyLine.FindSet();
        repeat
            ExtendedTextLine.SetRange(Text, AssemblyLine.Description);
            Assert.RecordIsNotEmpty(ExtendedTextLine);
        until AssemblyLine.Next() = 0;
    end;

    procedure VerifyAssemblyLine(Exists: Boolean; DocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20]; LineType: Enum "BOM Component Type"; No: Code[20])
    var
        AssemblyHeader: Record "Assembly Header";
        AssemblyLine: Record "Assembly Line";
    begin
        AssemblyHeader.Get(DocumentType, AssemblyDocNo);

        SetAssemblyLineFilter(DocumentType, AssemblyDocNo, LineType, No, AssemblyLine);
        if Exists then
            Assert.RecordIsNotEmpty(AssemblyLine)
        else
            Assert.RecordIsEmpty(AssemblyLine);
    end;

    procedure VerifyNoExtendedTextLinesAreAddedToAssemblyDocument(DocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20])
    var
        AssemblyHeader: Record "Assembly Header";
        AssemblyLine: Record "Assembly Line";
    begin
        AssemblyHeader.Get(DocumentType, AssemblyDocNo);
        AssemblyLine.SetRange("Document Type", DocumentType);
        AssemblyLine.SetRange("Document No.", AssemblyDocNo);
        AssemblyLine.SetRange(Type, AssemblyLine.Type::" ");
        AssemblyLine.SetRange("No.", '');
        Assert.RecordIsEmpty(AssemblyLine);
    end;

    procedure VerifyItemAndExtendedTextLinesAreRemoved(DocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20]; ItemNo: Code[20])
    var
        AssemblyLine: Record "Assembly Line";
    begin
        VerifyAssemblyLine(false, DocumentType, AssemblyDocNo, AssemblyLine.Type::Item, ItemNo);
        VerifyNoExtendedTextLinesAreAddedToAssemblyDocument(DocumentType, AssemblyDocNo);
    end;

    procedure VerifyResourceAndExtendedTextLinesAreRemoved(DocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20]; ResourceNo: Code[20])
    var
        AssemblyLine: Record "Assembly Line";
    begin
        VerifyAssemblyLine(false, DocumentType, AssemblyDocNo, AssemblyLine.Type::Resource, ResourceNo);
        VerifyNoExtendedTextLinesAreAddedToAssemblyDocument(DocumentType, AssemblyDocNo);
    end;

    procedure VerifyTextAndExtendedTextLinesAreRemoved(DocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20]; TextCode: Code[20])
    var
        AssemblyLine: Record "Assembly Line";
    begin
        VerifyAssemblyLine(false, DocumentType, AssemblyDocNo, AssemblyLine.Type::" ", TextCode);
        VerifyNoExtendedTextLinesAreAddedToAssemblyDocument(DocumentType, AssemblyDocNo);
    end;

    procedure VerifyReplacementAndExtendedTextLinesAreRemoved(DocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20]; Type: Enum "BOM Component Type"; No: array[2] of Code[20])
    var
        AssemblyHeader: Record "Assembly Header";
        AssemblyLine: Record "Assembly Line";
    begin
        AssemblyHeader.Get(DocumentType, AssemblyDocNo);
        VerifyAssemblyLine(false, DocumentType, AssemblyDocNo, Type, No[1]);
        VerifyAssemblyLine(true, DocumentType, AssemblyDocNo, Type, No[2]);
        VerifyNoExtendedTextLinesAreAddedToAssemblyDocument(DocumentType, AssemblyDocNo);
    end;
    #endregion verification methods

    #region general methods
    procedure SetNosOnAssemblySetup()
    var
        AssemblySetup: Record "Assembly Setup";
        LibraryUtility: Codeunit "Library - Utility 2 FLX";
    begin
        if not AssemblySetup.Get() then
            AssemblySetup.Insert();
        LibraryUtility.UpdateSetupNoSeriesCode(
            Database::"Assembly Setup", AssemblySetup.FieldNo("Assembly Quote Nos."));
        LibraryUtility.UpdateSetupNoSeriesCode(
            Database::"Assembly Setup", AssemblySetup.FieldNo("Assembly Order Nos."));
        LibraryUtility.UpdateSetupNoSeriesCode(
            Database::"Assembly Setup", AssemblySetup.FieldNo("Blanket Assembly Order Nos."));
        LibraryUtility.UpdateSetupNoSeriesCode(
            Database::"Assembly Setup", AssemblySetup.FieldNo("Posted Assembly Order Nos."));
    end;

    procedure GetAssemblyDocumentType(): Enum "Assembly Document Type"
    var
        AITTestContext: Codeunit "AIT Test Context";
        AssemblyDocumentType: Text;
    begin
        AssemblyDocumentType := AITTestContext.GetTestSetup().Element('AssemblyDocumentType').ValueAsText();

        case AssemblyDocumentType of
            'Order':
                exit("Assembly Document Type"::Order);
            'Quote':
                exit("Assembly Document Type"::Quote);
            'Blanket Order':
                exit("Assembly Document Type"::"Blanket Order");
            else
                ThrowInvalidAssemblyDocumentError(AssemblyDocumentType);
        end;
    end;

    internal procedure ThrowInvalidAssemblyDocumentError(AssemblyDocumentType: Text)
    var
        InvalidAssemblyDocumentTypeErr: Label 'Invalid Assembly Document Type: %1', Comment = '%1 is the Assembly Document Type';
    begin
        error(InvalidAssemblyDocumentTypeErr, AssemblyDocumentType);
    end;
    #endregion general methods

    var
        Assert: Codeunit "Assert 2 FLX";
}