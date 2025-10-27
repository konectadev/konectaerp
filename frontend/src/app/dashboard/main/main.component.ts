import { Component, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { Subject, takeUntil } from 'rxjs';
import { AuthService, User } from '../../core/services/auth.service';

interface DashboardCard {
  title: string;
  description: string;
  icon: string;
  route: string;
  roles: string[];
  stats?: { label: string; value: string }[];
}

@Component({
  selector: 'app-main',
  imports: [CommonModule, RouterModule],
  templateUrl: './main.component.html',
  styleUrl: './main.component.scss'
})
export class MainComponent implements OnInit, OnDestroy {
  currentUser: User | null = null;
  filteredCards: DashboardCard[] = [];
  private destroy$ = new Subject<void>();

  constructor(private authService: AuthService) {}

  ngOnInit(): void {
    this.authService.currentUser$
      .pipe(takeUntil(this.destroy$))
      .subscribe(user => {
        this.currentUser = user;
        this.updateFilteredCards();
      });
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }

  private updateFilteredCards(): void {
    const allCards: DashboardCard[] = [
      {
        title: 'HR Management',
        description: 'Manage employees, roles, and organizational structure',
        icon: '👥',
        route: '/hr',
        roles: ['Admin', 'Manager'],
        stats: [
          { label: 'Total Employees', value: '--' },
          { label: 'Departments', value: '--' }
        ]
      },
      {
        title: 'Finance',
        description: 'Track expenses, budgets, and financial reports',
        icon: '💰',
        route: '/finance',
        roles: ['Admin', 'Manager', 'Employee'],
        stats: [
          { label: 'Monthly Budget', value: '$--' },
          { label: 'Expenses', value: '$--' }
        ]
      },
      {
        title: 'Inventory',
        description: 'Manage products, stock levels, and suppliers',
        icon: '📦',
        route: '/inventory',
        roles: ['Admin', 'Manager', 'Employee'],
        stats: [
          { label: 'Total Items', value: '--' },
          { label: 'Low Stock', value: '--' }
        ]
      },
      {
        title: 'Reports',
        description: 'View analytics and generate reports',
        icon: '📊',
        route: '/reports',
        roles: ['Admin', 'Manager'],
        stats: [
          { label: 'Reports Generated', value: '--' },
          { label: 'Pending', value: '--' }
        ]
      },
      {
        title: 'Settings',
        description: 'Configure system settings and user management',
        icon: '⚙️',
        route: '/settings',
        roles: ['Admin'],
        stats: [
          { label: 'Active Users', value: '--' },
          { label: 'Roles', value: '--' }
        ]
      },
      {
        title: 'My Tasks',
        description: 'View and manage your assigned tasks',
        icon: '✔️',
        route: '/tasks',
        roles: ['Admin', 'Manager', 'Employee'],
        stats: [
          { label: 'Pending Tasks', value: '--' },
          { label: 'Completed', value: '--' }
        ]
      }
    ];

    if (!this.currentUser) {
      this.filteredCards = [];
      return;
    }

    this.filteredCards = allCards.filter(card =>
      card.roles.some(role => this.authService.hasRole(role))
    );
  }

  hasRole(role: string): boolean {
    return this.authService.hasRole(role);
  }
}
