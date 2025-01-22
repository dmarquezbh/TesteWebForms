using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;

namespace TesteWebforms.Teste
{
    public partial class TesteDaniel2 : System.Web.UI.Page
    {
        protected HtmlForm form1;
       
        protected TextBox TextBox1;

        protected Button Button1;

        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void Button1_Click(object sender, EventArgs e)
        {
            TextBox1.Text = "Teste " + DateTime.Now.ToString("dd/MM/yyyy HH:mm:ss.fffff");
        }
    }
}