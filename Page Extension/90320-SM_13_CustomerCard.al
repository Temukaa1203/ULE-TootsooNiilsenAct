pageextension 90320 SM_13_CustomerCard extends "Customer Card"
{
    layout
    {
        // addbefore("Phone No.")
        // {
        //     field("Receive SMS"; Rec."Receive SMS")
        //     {
        //         ApplicationArea = All;
        //     }
        // } 
    }

    actions
    {
        addfirst(processing)
        {
            action("Print Balance")
            {
                Caption = 'Тооцоо нийлсэн акт';
                Image = Report;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    Rec.Reset;
                    Rec.SetRange("No.", Rec."No.");
                    Report.Run(Report::"Customer Balance", true, false, Rec);
                end;
            }
        }
    }
}