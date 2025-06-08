codeunit 76468 "Ext. Text Rpl. Res. AD DDT FLX"
{
    // Generated on 2025-06-07 by lvanvugt

    Subtype = Test;

    trigger OnRun()
    begin
        // [FEATURE] Extended Text for replace resource line on assembly document
    end;

    [Test]
    procedure ReplaceResourceWithExtendedTextsByResourceWithoutExtendedTextsOnAssemblyDocument()
    var
        AssemblyDocumentType: Enum "Assembly Document Type";
        AutomaticExtTextsEnabled, ExtendedTextEnabled : Boolean;
        CreatedNoOfExtendedTextLines: Integer;
        AssemblyDocNo: Code[20];
        ResourceNo: array[2] of Code[20];
    begin
        // [SCENARIO #0030] Replace resource with extended texts by resource without extended texts on assembly order line
        // [SCENARIO #0037] Replace resource with extended texts by resource without extended texts on assembly quote line
        // [SCENARIO #0044] Replace resource with extended texts by resource without extended texts on blanket blanket assembly order line
        Initialize();

        AssemblyDocumentType := GetAssemblyDocumentType();
        AutomaticExtTextsEnabled := AITTestContext.GetTestSetup().Element('Automatic Ext. Texts Enabled').ValueAsBoolean();
        ExtendedTextEnabled := AITTestContext.GetTestSetup().Element('Extended Text Enabled').ValueAsBoolean();
        CreatedNoOfExtendedTextLines := AITTestContext.GetExpectedData().Element('Created No. of Extended Text Lines').ValueAsInteger();

        // [GIVEN] Resource with "Automatic Ext. Texts" disabled and extended text enabled for assembly document
        ResourceNo[1] := CreateResourceWithExtendedText(AutomaticExtTextsEnabled, AssemblyDocumentType, ExtendedTextEnabled);
        // [GIVEN] Resource with no extended text
        ResourceNo[2] := CreateResourceWithNoExtendedText();
        // [GIVEN] Assembly order with resource line and extended text inserted
        AssemblyDocNo := CreateAssemblyDocumentWithResourceLineAndExtendedTextInserted(AssemblyDocumentType, ResourceNo[1]);

        // [WHEN] Replace resource by resource with no extended text
        ReplaceResourceByResourceWithNoExtendedTextOnAssemblyOrderPage(AssemblyDocumentType, AssemblyDocNo, ResourceNo);

        // [THEN] Resource is replaced and extended text lines are removed
        VerifyResourceIsReplacedAndExtendedTextLinesAreRemoved(AssemblyDocumentType, AssemblyDocNo, ResourceNo);
    end;

    var
        LibraryExtTextAssDoc: Codeunit "Library - Ext Text Ass Doc FLX";
        AITTestContext: Codeunit "AIT Test Context";
        IsInitialized: Boolean;

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize FLX";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Ext. Text Rpl. Res. AD DDT FLX");

        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Ext. Text Rpl. Res. AD DDT FLX");

        // [GIVEN] Set Nos on assembly setup
        SetNosOnAssemblySetup();

        IsInitialized := true;
        Commit();

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Ext. Text Rpl. Res. AD DDT FLX");
    end;

    local procedure SetNosOnAssemblySetup()
    begin
        LibraryExtTextAssDoc.SetNosOnAssemblySetup();
    end;

    local procedure CreateAssemblyDocument(AssemblyDocumentType: Enum "Assembly Document Type"): Code[20]
    begin
        exit(LibraryExtTextAssDoc.CreateAssemblyDocument(AssemblyDocumentType));
    end;

    local procedure CreateAssemblyDocumentWithResourceLine(AssemblyDocumentType: Enum "Assembly Document Type"; ResourceNo: Code[20]): Code[20]
    var
        AssemblyHeader: Record "Assembly Header";
        AssemblyLine: Record "Assembly Line";
        LibraryAssembly: Codeunit "Library - Assembly 2 FLX";
        AssemblyDocNo: Code[20];
    begin
        AssemblyDocNo := CreateAssemblyDocument(AssemblyDocumentType);
        AssemblyHeader.Get(AssemblyDocumentType, AssemblyDocNo);
        LibraryAssembly.CreateAssemblyLine(AssemblyHeader, AssemblyLine, AssemblyLine.Type::Resource, ResourceNo, LibraryExtTextAssDoc.CreateResourceUnitOfMeasureCode(ResourceNo), 1, 1, '');
        exit(AssemblyHeader."No.");
    end;

    local procedure CreateAssemblyDocumentWithResourceLineAndExtendedTextInserted(AssemblyDocumentType: Enum "Assembly Document Type"; ResourceNo: Code[20]): Code[20]
    var
        AssemblyDocNo: Code[20];
    begin
        AssemblyDocNo := CreateAssemblyDocumentWithResourceLine(AssemblyDocumentType, ResourceNo);
        InsertExtendedText(AssemblyDocumentType, AssemblyDocNo, ResourceNo);
        exit(AssemblyDocNo);
    end;

    local procedure CreateResourceWithNoExtendedText(): Code[20]
    begin
        exit(LibraryExtTextAssDoc.CreateResourceWithNoExtendedText());
    end;

    local procedure CreateResourceWithExtendedText(AutomaticExtTextsEnabled: Boolean; AssemblyDocumentType: Enum "Assembly Document Type"; ExtendedTextEnabled: Boolean): Code[20]
    begin
        exit(LibraryExtTextAssDoc.CreateResourceWithExtendedText(AutomaticExtTextsEnabled, AssemblyDocumentType, ExtendedTextEnabled));
    end;

    local procedure InsertExtendedText(AssemblyDocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20]; ResourceNo: Code[20])
    var
        AssemblyLine: Record "Assembly Line";
    begin
        LibraryExtTextAssDoc.InsertExtendedText(AssemblyDocumentType, AssemblyDocNo, AssemblyLine.Type::Resource, ResourceNo);
    end;

    local procedure ReplaceResourceByResourceWithNoExtendedTextOnAssemblyOrderPage(AssemblyDocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20]; ResourceNo: array[2] of Code[20])
    var
        AssemblyHeader: Record "Assembly Header";
        AssemblyLine: Record "Assembly Line";
        AssemblyOrderPage: TestPage "Assembly Order";
        AssemblyQuotePage: TestPage "Assembly Quote";
        AssemblyBlanketOrderPage: TestPage "Blanket Assembly Order";
    begin
        AssemblyHeader.Get(AssemblyDocumentType, AssemblyDocNo);

        LibraryExtTextAssDoc.FindAssemblyLine(AssemblyDocumentType, AssemblyDocNo, AssemblyLine.Type::Resource, ResourceNo[1], AssemblyLine);

        case AssemblyDocumentType of
            "Assembly Document Type"::Order:
                begin
                    AssemblyOrderPage.OpenEdit();
                    AssemblyOrderPage.GoToRecord(AssemblyHeader);
                    AssemblyOrderPage.Lines.GoToRecord(AssemblyLine);
                    AssemblyOrderPage.Lines.Type.SetValue(AssemblyLine.Type::Resource);
                    AssemblyOrderPage.Lines."No.".SetValue(ResourceNo[2]);
                    AssemblyOrderPage.Close();
                end;
            "Assembly Document Type"::Quote:
                begin
                    AssemblyQuotePage.OpenEdit();
                    AssemblyQuotePage.GoToRecord(AssemblyHeader);
                    AssemblyQuotePage.Lines.Type.SetValue(AssemblyLine.Type::Resource);
                    AssemblyQuotePage.Lines."No.".SetValue(ResourceNo[2]);
                    AssemblyQuotePage.Close();
                end;
            "Assembly Document Type"::"Blanket Order":
                begin
                    AssemblyBlanketOrderPage.OpenEdit();
                    AssemblyBlanketOrderPage.GoToRecord(AssemblyHeader);
                    AssemblyBlanketOrderPage.Lines.Type.SetValue(AssemblyLine.Type::Resource);
                    AssemblyBlanketOrderPage.Lines."No.".SetValue(ResourceNo[2]);
                    AssemblyBlanketOrderPage.Close();
                end;
            else
                LibraryExtTextAssDoc.ThrowInvalidAssemblyDocumentError(Format(AssemblyDocumentType));
        end;
    end;

    local procedure VerifyExtendedTextLinesAreAddedToAssemblyDocument(AssemblyDocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20]; ResourceNo: Code[20]; CreatedNoOfExtendedTextLines: Integer)
    var
        AssemblyLine:
            Record "Assembly Line";
    begin
        LibraryExtTextAssDoc.VerifyExtendedTextLinesAreAddedToAssemblyDocument(AssemblyDocumentType, AssemblyDocNo, AssemblyLine.Type::Resource, ResourceNo, 1);
    end;

    local procedure VerifyResourceIsReplacedAndExtendedTextLinesAreRemoved(AssemblyDocumentType: Enum "Assembly Document Type"; AssemblyDocNo: Code[20]; ResourceNo: array[2] of Code[20])
    var
        AssemblyLine: Record "Assembly Line";
    begin
        LibraryExtTextAssDoc.VerifyReplacementAndExtendedTextLinesAreRemoved(AssemblyDocumentType, AssemblyDocNo, AssemblyLine.Type::Resource, ResourceNo);
    end;

    local procedure GetAssemblyDocumentType(): Enum "Assembly Document Type"
    var
        AssemblyDocumentType: Text;
    begin
        exit(LibraryExtTextAssDoc.GetAssemblyDocumentType());
    end;
}