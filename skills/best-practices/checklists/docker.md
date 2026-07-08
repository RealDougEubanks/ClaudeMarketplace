# Docker / Infrastructure Checks

- [ ] Base image uses `latest` tag instead of pinned version
- [ ] Running as root user in container
- [ ] No `.dockerignore` (copies node_modules, .git, .env into image)
- [ ] Secrets passed as `ENV` or `ARG` in Dockerfile
- [ ] Large image size (unnecessary build tools in final image — use multi-stage builds)
- [ ] No health check defined
- [ ] No resource limits defined (memory, CPU)
