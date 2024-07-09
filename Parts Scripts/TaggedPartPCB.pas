// TaggedPartPCB.pas
// The Script creates a TaggedPart.log file for the selected Part in the Current PCBDoc.
// TaggedPart.log is Read by Parts_Frontend.accde when the Tagged Label is Selected in Parts.
// This script should be located in a folder on the user's machine (local drive), i.e. C Drive

// Randy Clemmons April 29, 2024
// https://pcbparts.blogspot.com/p/contact-us.html

Procedure TaggedPartPCB;

var
    Board           : IPCB_Board;
    Iterator        : IPCB_BoardIterator;
    ThisObject      : IPCB_Component;
    Document        : IServerDocument;

    LibName    : WideString;    // DBLIB Name
    TableName  : WideString;    // Table Name
    PartID     : WideString;    // Design Item ID
    Libref     : WideString;    // LibRef
    FileName   : WideString;
    txtFile    : TextFile;

Begin

    // Initialize Variables
    LibName := '';
    TableName := '';
    PartID := '';
    Libref := '';
    FileName := 'C:\Parts_x64\Parts Scripts\TaggedPart.log';

    Board := PCBServer.GetCurrentPCBBoard;
    if Board = nil then
    begin
         ShowMessage('Active Window is Not a .PcbDoc File');
         exit;
    end;

        // Find the object(s) of interest
        Iterator := Board.BoardIterator_Create;
        Iterator.SetState_FilterAll;
        Iterator.Addfilter_ObjectSet(mkSet(eComponentObject));
        ThisObject := Iterator.FirstPCBObject;

        While (ThisObject <> Nil) do
        begin
            If ThisObject.Selected = True then
            begin

                // LibName : = ThisObject.SourceFootprintLibrary;

                LibName : = ThisObject.SourceComponentLibrary;
                TableName : = 'parts'; // Default Table Name
                PartID := ThisObject.SourceCompDesignItemID;
                Libref := ThisObject.Pattern;

                AssignFile(txtFile, FileName);
                ReWrite(txtFile);
                Write(txtFile, 'LibName := ' + LibName + #13#10);
                Write(txtFile, 'TableName := ' + TableName + #13#10);
                Write(txtFile, 'PartID := ' + PartID + #13#10);
                Write(txtFile, 'Libref := ' + Libref + #13#10);

               CloseFile(txtFile);

               If not FileExists(FileName) then
               begin
                  showinfo(FileName,'Tagged File Not Found');
               end;

               Break;  // Exit While Loop After Displaying First Selected Part

            end;
            ThisObject := Iterator.NextPCBObject;
        end;

        Board.BoardIterator_Destroy(Iterator);
    end;

End;


