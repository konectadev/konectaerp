import { Component, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { Subject, takeUntil } from 'rxjs';
import { AuthService, User } from '../../core/services/auth.service';

interface MenuItem {
  label: string;
  icon: string;
  route: string;
  roles: string[];
}

@Component({
  selector: 'app-sidebar',
  imports: [CommonModule, RouterModule],
  templateUrl: './sidebar.component.html',
  styleUrl: './sidebar.component.scss'
})
export class SidebarComponent implements OnInit, OnDestroy {
  currentUser: User | null = null;
  menuItems: MenuItem[] = [
    { label: 'Dashboard', icon: '📊', route: '/dashboard', roles: ['Admin', 'Manager', 'Employee'] },
    { label: 'HR Management', icon: '👥', route: '/hr', roles: ['Admin', 'Manager'] },
    { label: 'User Management', icon: '👤', route: '/users', roles: ['Admin'] },
    { label: 'Finance', icon: '💰', route: '/finance', roles: ['Admin', 'Manager', 'Employee'] },
    { label: 'Inventory', icon: '📦', route: '/inventory', roles: ['Admin', 'Manager', 'Employee'] },
    { label: 'Tasks', icon: '✔️', route: '/tasks', roles: ['Admin', 'Manager', 'Employee'] },
    { label: 'Reports', icon: '📈', route: '/reports', roles: ['Admin', 'Manager'] },
    { label: 'Settings', icon: '⚙️', route: '/settings', roles: ['Admin'] }
  ];
  filteredMenuItems: MenuItem[] = [];
  private destroy$ = new Subject<void>();

  constructor(private authService: AuthService) {}

  ngOnInit(): void {
    this.authService.currentUser$
      .pipe(takeUntil(this.destroy$))
      .subscribe(user => {
        this.currentUser = user;
        this.filterMenuItems();
      });
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }

  private filterMenuItems(): void {
    if (!this.currentUser) {
      this.filteredMenuItems = [];
      return;
    }

    this.filteredMenuItems = this.menuItems.filter(item => {
      return item.roles.some(role => this.authService.hasRole(role));
    });
  }

  hasRole(role: string): boolean {
    return this.authService.hasRole(role);
  }
}
