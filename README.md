# dmib-spring-boot-test

## GitHub Packages Authentication

This project depends on private GitHub packages from the Equinor organization. To build and run this project, you need to set up authentication:

### Local Development

1. Create a GitHub Personal Access Token with `read:packages` scope at [GitHub Settings](https://github.com/settings/tokens)
2. Set environment variables:

   ```cmd
   set PACKAGES_USER_NAME=your-github-username
   set PACKAGES_USER_TOKEN=your-github-personal-access-token
   ```

### CI/CD Environment

The project uses GitHub Actions for CI/CD. The workflow for Dependency Submission has been configured to authenticate with GitHub Packages using the built-in `GITHUB_TOKEN`.
