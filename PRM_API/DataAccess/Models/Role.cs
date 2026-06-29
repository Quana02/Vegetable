namespace DataAccess.Models;

public class Role
{
    public byte Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string DisplayName { get; set; } = string.Empty;
    public ICollection<Account> Accounts { get; set; } = [];
}
