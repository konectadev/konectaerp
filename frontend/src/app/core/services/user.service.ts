import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface UserDto {
  id: string;
  username: string;
  email: string;
  firstName: string;
  lastName: string;
  isActive: boolean;
  createdAt: string;
  lastLoginAt?: string;
  roles: string[];
}

export interface CreateUserDto {
  username: string;
  email: string;
  firstName: string;
  lastName: string;
  isActive: boolean;
  roleIds: string[];
}

export interface UpdateUserDto {
  username: string;
  email: string;
  firstName: string;
  lastName: string;
  isActive: boolean;
  roleIds: string[];
}

export interface RoleDto {
  id: string;
  name: string;
  description?: string;
  createdAt: string;
}

export interface AssignRolesDto {
  roleIds: string[];
}

@Injectable({
  providedIn: 'root'
})
export class UserService {
  private readonly API_BASE = 'http://localhost:5002/api'; // UserManagementService

  constructor(private http: HttpClient) { }

  private getHeaders(): HttpHeaders {
    const token = localStorage.getItem('auth_token');
    return new HttpHeaders({
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    });
  }

  // User operations
  getAllUsers(): Observable<UserDto[]> {
    return this.http.get<UserDto[]>(`${this.API_BASE}/users`, { headers: this.getHeaders() });
  }

  getUserById(id: string): Observable<UserDto> {
    return this.http.get<UserDto>(`${this.API_BASE}/users/${id}`, { headers: this.getHeaders() });
  }

  createUser(user: CreateUserDto): Observable<UserDto> {
    return this.http.post<UserDto>(`${this.API_BASE}/users`, user, { headers: this.getHeaders() });
  }

  updateUser(id: string, user: UpdateUserDto): Observable<UserDto> {
    return this.http.put<UserDto>(`${this.API_BASE}/users/${id}`, user, { headers: this.getHeaders() });
  }

  deleteUser(id: string): Observable<void> {
    return this.http.delete<void>(`${this.API_BASE}/users/${id}`, { headers: this.getHeaders() });
  }

  assignRoles(userId: string, roleIds: string[]): Observable<any> {
    return this.http.post<any>(
      `${this.API_BASE}/users/${userId}/roles`,
      { roleIds },
      { headers: this.getHeaders() }
    );
  }

  removeRole(userId: string, roleId: string): Observable<any> {
    return this.http.delete<any>(
      `${this.API_BASE}/users/${userId}/roles/${roleId}`,
      { headers: this.getHeaders() }
    );
  }

  // Role operations
  getAllRoles(): Observable<RoleDto[]> {
    return this.http.get<RoleDto[]>(`${this.API_BASE}/roles`, { headers: this.getHeaders() });
  }

  getRoleById(id: string): Observable<RoleDto> {
    return this.http.get<RoleDto>(`${this.API_BASE}/roles/${id}`, { headers: this.getHeaders() });
  }
}
