using DataAccess.Models;
using Microsoft.AspNetCore.Mvc;
using Repositories;
using vegetable_api.Contracts;

namespace vegetable_api.Controllers;

[ApiController]
[Route("api/categories")]
public class CategoriesController(IRepository<Category> repository) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<CategoryDto>>> GetAll(CancellationToken cancellationToken) =>
        Ok((await repository.ListAsync(x => x.IsActive, cancellationToken))
            .OrderBy(x => x.Name)
            .Select(x => new CategoryDto(x.Id, x.Name, x.Slug, x.Description)));
}
