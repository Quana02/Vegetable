namespace DataAccess.Models;

public enum AuthProvider
{
    Local,
    Google
}

public enum OrderStatus
{
    Pending,
    Confirmed,
    Shipping,
    Completed,
    Cancelled
}

public enum PaymentMethod
{
    Cod,
    BankTransfer,
    Momo,
    VnPay
}

public enum PaymentStatus
{
    Unpaid,
    Paid,
    Refunded,
    Failed
}
