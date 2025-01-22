namespace TesteWebforms
{
    public partial class Default
    {
#if NETFRAMEWORK
        protected global::System.Web.UI.HtmlControls.HtmlForm form1;
        protected global::System.Web.UI.WebControls.Label lblName;
        protected global::System.Web.UI.WebControls.TextBox txtName;
        protected global::System.Web.UI.WebControls.Button btnAdd;
        protected global::System.Web.UI.WebControls.Panel pnlMessage;
        protected global::System.Web.UI.WebControls.Literal litMessage;
        protected global::System.Web.UI.WebControls.GridView gvPessoas;
        protected global::System.Web.UI.WebControls.Label lblDateTime;
        protected global::System.Web.UI.Timer tmrDateTime;
        protected global::System.Web.UI.ScriptManager ScriptManager1;
        protected global::System.Web.UI.UpdatePanel upDateTime;
        protected global::System.Web.UI.WebControls.Label lblCurrentTime;
#endif
    }
}
