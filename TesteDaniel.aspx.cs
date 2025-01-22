using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;

public partial class TesteDaniel : System.Web.UI.Page
{
    // Declaração explícita dos controles
    protected HtmlForm form1;
    protected Label Label1;
    protected Button Button1;

    protected void Page_Load(object sender, EventArgs e)
    {
    }

    protected void Button1_Click(object sender, EventArgs e)
    {
        Label1.Text = "daniel " + DateTime.Now.ToString("dd/MM/yyyy HH:mm:ss.fffff");
    }
}