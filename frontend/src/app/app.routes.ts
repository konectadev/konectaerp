import { Routes } from '@angular/router';
import { authGuard } from './core/guards/auth.guard';
import { roleGuard } from './core/guards/role.guard';

export const routes: Routes = [
  {
    path: 'auth',
    loadChildren: () => import('./auth/auth.routes').then(m => m.authRoutes)
  },
  {
    path: 'dashboard',
    loadChildren: () => import('./dashboard/dashboard-routing.module').then(m => m.DashboardRoutingModule),
    canActivate: [authGuard]
  },
  {
    path: 'hr',
    loadChildren: () => import('./hr/hr-routing.module').then(m => m.HrRoutingModule),
    canActivate: [authGuard, roleGuard],
    data: { roles: ['Admin', 'Manager'] }
  },
  {
    path: 'finance',
    loadChildren: () => import('./finance/finance-routing.module').then(m => m.FinanceRoutingModule),
    canActivate: [authGuard]
  },
  {
    path: 'inventory',
    loadChildren: () => import('./inventory/inventory-routing.module').then(m => m.InventoryRoutingModule),
    canActivate: [authGuard]
  },
  {
    path: 'reports',
    loadComponent: () => import('./shared/components/reports-overview.component').then(m => m.ReportsOverviewComponent),
    canActivate: [authGuard, roleGuard],
    data: { roles: ['Admin', 'Manager'] }
  },
  {
    path: 'settings',
    loadComponent: () => import('./shared/components/settings-overview.component').then(m => m.SettingsOverviewComponent),
    canActivate: [authGuard, roleGuard],
    data: { roles: ['Admin'] }
  },
  {
    path: 'users',
    loadComponent: () => import('./shared/components/user-management.component').then(m => m.UserManagementComponent),
    canActivate: [authGuard, roleGuard],
    data: { roles: ['Admin'] }
  },
  {
    path: 'tasks',
    loadComponent: () => import('./shared/components/tasks-overview.component').then(m => m.TasksOverviewComponent),
    canActivate: [authGuard]
  },
  {
    path: '',
    redirectTo: '/dashboard',
    pathMatch: 'full'
  },
  {
    path: '**',
    redirectTo: '/dashboard'
  }
];
