from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import jwt, JWTError
from typing import List
from models import Project
from config import SECRET_KEY, ALGORITHM
from storage import projects

app = FastAPI()

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="http://localhost:8000/token")  # URL user_service

async def get_current_user(token: str = Depends(oauth2_scheme)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
        return username
    except JWTError:
        raise credentials_exception

@app.post("/projects", response_model=Project)
def create_project(project: Project, current_user: str = Depends(get_current_user)):
    new_id = len(projects) + 1
    new_project = Project(id=new_id, name=project.name, description=project.description, members=project.members)
    projects[new_id] = new_project
    return new_project

@app.get("/projects", response_model=List[Project])
def get_projects(current_user: str = Depends(get_current_user)):
    return list(projects.values())

@app.get("/projects/{project_id}", response_model=Project)
def get_project(project_id: int, current_user: str = Depends(get_current_user)):
    if project_id not in projects:
        raise HTTPException(status_code=404, detail="Project not found")
    return projects[project_id]

@app.put("/projects/{project_id}", response_model=Project)
def update_project(project_id: int, updated_project: Project, current_user: str = Depends(get_current_user)):
    if project_id not in projects:
        raise HTTPException(status_code=404, detail="Project not found")
    projects[project_id] = Project(id=project_id, name=updated_project.name, description=updated_project.description, members=updated_project.members)
    return projects[project_id]

@app.delete("/projects/{project_id}", response_model=Project)
def delete_project(project_id: int, current_user: str = Depends(get_current_user)):
    if project_id not in projects:
        raise HTTPException(status_code=404, detail="Project not found")
    deleted_project = projects.pop(project_id)
    return deleted_project
